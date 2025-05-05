// import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';

class QuizPage extends StatefulWidget {
  final String quizId;
  const QuizPage({Key? key, required this.quizId}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final apiService = ApiService(baseUrl: 'http://localhost:2020');
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  Map<String, int> selectedAnswers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("Token tidak ditemukan");
      return;
    }

    try {
      final apiService = ApiService(baseUrl: "http://localhost:2020");
      final result = await apiService.fetchQuizQuestions(
        quizId: widget.quizId,
        token: token,
      );

      setState(() {
        questions = result;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading questions: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _submitQuiz() async {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text("Kirim Jawaban"),
            content: Text("Yakin ingin mengirim semua jawaban?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();

                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('token');

                  if (token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Token tidak ditemukan, silakan login kembali",
                        ),
                      ),
                    );
                    return;
                  }

                  var response = await apiService.submitQuizResult(
                    quizId: widget.quizId,
                    answers: selectedAnswers,
                    token: token,
                  );

                  print("Selected answers: $selectedAnswers");
                  print("Response: $response");

                  if (response['error'] != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gagal mengirim jawaban")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Jawaban berhasil dikirim")),
                    );
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/child_dashboard',
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                child: Text("Kirim"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Loading...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final rawOptions = currentQuestion['options'];
    final options =
        rawOptions is List ? List<String>.from(rawOptions) : <String>[];
    final questionId = currentQuestion['id'];

    return Scaffold(
      appBar: AppBar(title: Text("Quiz"), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Question info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Soal ${currentQuestionIndex + 1}/${questions.length}",
                  style: TextStyle(fontSize: 16),
                ),
                // Placeholder Timer
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text("00:30", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 20),

            /// Question text
            Text(
              currentQuestion['question'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            /// Options
            ...List.generate(options.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAnswers[questionId] = index;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        selectedAnswers[questionId] == index
                            ? Colors.deepPurple[100]
                            : Colors.white,
                    border: Border.all(
                      color:
                          selectedAnswers[questionId] == index
                              ? Colors.deepPurple
                              : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selectedAnswers[questionId] == index
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: Colors.deepPurple,
                      ),
                      SizedBox(width: 10),
                      Expanded(child: Text(options[index])),
                    ],
                  ),
                ),
              );
            }),

            Spacer(),

            /// Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      currentQuestionIndex > 0
                          ? () {
                            setState(() {
                              currentQuestionIndex--;
                            });
                          }
                          : null,
                  icon: Icon(Icons.arrow_back),
                  label: Text("Sebelumnya"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (currentQuestionIndex == questions.length - 1) {
                      _submitQuiz();
                    } else {
                      setState(() {
                        currentQuestionIndex++;
                      });
                    }
                  },
                  icon: Icon(
                    currentQuestionIndex == questions.length - 1
                        ? Icons.check
                        : Icons.arrow_forward,
                  ),
                  label: Text(
                    currentQuestionIndex == questions.length - 1
                        ? "Selesai"
                        : "Selanjutnya",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
