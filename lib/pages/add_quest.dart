import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lapar_fe/api/api_service.dart';

class AddQuestionPage extends StatefulWidget {
  final String quizId;

  const AddQuestionPage({super.key, required this.quizId});

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final TextEditingController _correctAnswerController =
      TextEditingController();

  Future<void> _submitQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Token tidak ditemukan")));
      return;
    }

    try {
      await ApiService(baseUrl: 'http://localhost:2020').addQuestionToQuiz(
        token: token,
        quizId: widget.quizId,
        question: _questionController.text,
        options: _optionControllers.map((e) => e.text).toList(),
        correctAnswer: _correctAnswerController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pertanyaan berhasil ditambahkan")),
      );

      _questionController.clear();
      _correctAnswerController.clear();
      for (final c in _optionControllers) {
        c.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text(
          "Tambah Pertanyaan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple[50]!, Colors.deepPurple[100]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _questionController,
                          decoration: InputDecoration(
                            labelText: 'Pertanyaan',
                            labelStyle: TextStyle(
                              color: Colors.deepPurple[700],
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.deepPurple[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.deepPurple[700]!,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        ...List.generate(
                          4,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: TextField(
                              controller: _optionControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Opsi ${index + 1}',
                                labelStyle: TextStyle(
                                  color: Colors.deepPurple[700],
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.deepPurple[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.deepPurple[700]!,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _correctAnswerController,
                          decoration: InputDecoration(
                            labelText: 'Jawaban Benar',
                            labelStyle: TextStyle(
                              color: Colors.deepPurple[700],
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.deepPurple[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.deepPurple[700]!,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _submitQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Tambah Pertanyaan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
