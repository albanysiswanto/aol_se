import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lapar_fe/api/api_service.dart';
import 'package:lapar_fe/pages/add_quest.dart';
import '../widgets/widget_popup.dart';

class AddQuizPage extends StatefulWidget {
  const AddQuizPage({super.key});

  @override
  State<AddQuizPage> createState() => _AddQuizPageState();
}

class _AddQuizPageState extends State<AddQuizPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rewardController = TextEditingController();
  final TextEditingController _timerController = TextEditingController();

  Future<void> _submitQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      showErrorPopup(context, "Token tidak ditemukan");
      return;
    }

    if (_titleController.text.isEmpty ||
        _rewardController.text.isEmpty ||
        _timerController.text.isEmpty) {
      showErrorPopup(context, "Semua field harus diisi");
      return;
    }

    try {
      final quizId = await ApiService(
        baseUrl: 'http://localhost:2020',
      ).createQuiz(
        token: token,
        title: _titleController.text,
        description: _descriptionController.text,
        reward: int.parse(_rewardController.text),
        timer: int.parse(_timerController.text),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Quiz berhasil dibuat")));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddQuestionPage(quizId: quizId)),
      );
    } catch (e) {
      showErrorPopup(context, "Gagal membuat quiz: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text(
          "Tambah Quiz",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Judul',
                          labelStyle: TextStyle(color: Colors.deepPurple[700]),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.deepPurple[200]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.deepPurple[400]!,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.title,
                            color: Colors.deepPurple[400],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi',
                          labelStyle: TextStyle(color: Colors.deepPurple[700]),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.deepPurple[200]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.deepPurple[400]!,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.description,
                            color: Colors.deepPurple[400],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _rewardController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Reward (menit)',
                          hintText: 'Contoh: 5',
                          labelStyle: TextStyle(color: Colors.deepPurple[700]),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.deepPurple[200]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.deepPurple[400]!,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.emoji_events,
                            color: Colors.deepPurple[400],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _timerController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Timer (menit)',
                          hintText: 'Contoh: 10',
                          labelStyle: TextStyle(color: Colors.deepPurple[700]),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.deepPurple[200]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.deepPurple[400]!,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.timer,
                            color: Colors.deepPurple[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  "Buat Quiz",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
