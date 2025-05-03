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
      appBar: AppBar(title: const Text("Tambah Pertanyaan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Pertanyaan'),
              ),
              ...List.generate(
                4,
                (index) => TextField(
                  controller: _optionControllers[index],
                  decoration: InputDecoration(labelText: 'Opsi ${index + 1}'),
                ),
              ),
              TextField(
                controller: _correctAnswerController,
                decoration: const InputDecoration(labelText: 'Jawaban Benar'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitQuestion,
                child: const Text("Tambah Pertanyaan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
