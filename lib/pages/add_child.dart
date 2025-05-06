import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddChildPage extends StatefulWidget {
  const AddChildPage({super.key});

  @override
  State<AddChildPage> createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  final _emailController = TextEditingController();
  final ApiService apiService = ApiService(baseUrl: 'http://localhost:2020');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleAddChild() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email tidak boleh kosong'),
          backgroundColor: Colors.deepPurple,
        ),
      );
      return;
    }

    // Ambil token dari SharedPreferences atau tempat penyimpanan lainnya
    final token = await _getTokenFromStorage();

    try {
      // final result = await apiService.inviteChild(email, token);
      final result = await apiService.inviteChild(email, token);

      if (!mounted) return;

      if (result.isEmpty || result.contains("error")) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Gagal'),
                content: Text('Terjadi kesalahan saat mengundang anak.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
        );
        return;
      }
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Berhasil',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(result),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
      );
      _emailController.clear();
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Gagal',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text('Terjadi kesalahan: ${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
      );
    }
  }

  Future<String> _getTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      print("Token tidak ditemukan di SharedPreferences.");
      return '';
    }
    return token;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: const Text(
                  'Tambah Anak',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.deepPurple),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.person_add_alt_1,
                                size: 60,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email Anak',
                                  labelStyle: const TextStyle(
                                    color: Colors.deepPurple,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.deepPurple,
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _handleAddChild,
                                  icon: const Icon(Icons.person_add),
                                  label: const Text(
                                    'Tambah Anak',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
