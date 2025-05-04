import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../pages/child_dashboard.dart';
import 'dart:convert';

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

  int timerInSeconds = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    loadQuestionsAndTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> loadQuestionsAndTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("Token tidak ditemukan");
      return;
    }

    try {
      final result = await apiService.fetchQuizDetailAndQuestions(
        quizId: widget.quizId,
        token: token,
      );

      // Check if the response has questions and timer before proceeding
      if (result != null &&
          result['questions'] != null &&
          result['timer'] != null) {
        setState(() {
          questions = result['questions'];
          timerInSeconds = result['timer'] ?? 60;
          isLoading = false;
        });

        startTimer();
      } else {
        print("Invalid quiz data");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading questions: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void startTimer() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timerInSeconds == 0) {
        timer.cancel();
        _autoSubmit();
      } else {
        setState(() {
          timerInSeconds--;
        });
      }
    });
  }

  void _autoSubmit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Waktu habis! Jawaban dikirim otomatis.")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ChildDashboard()),
    );
  }

  void _submitQuiz() {
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
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _countdownTimer?.cancel();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Jawaban berhasil dikirim")),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ChildDashboard()),
                  );
                },
                child: Text("Kirim"),
              ),
            ],
          ),
    );
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Loading...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz")),
        body: Center(child: Text("Soal tidak tersedia")),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final rawOptions = currentQuestion['options'];
    final options =
        rawOptions is String
            ? List<String>.from(jsonDecode(rawOptions))
            : List<String>.from(rawOptions);

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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    formatTime(timerInSeconds),
                    style: TextStyle(color: Colors.white),
                  ),
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
