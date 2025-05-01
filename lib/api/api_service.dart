import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/register_request.dart';
import '../models/login_request.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<String> registerUser(RegisterRequest request) async {
    final url = Uri.parse('$baseUrl/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal registrasi: ${response.body}');
    }

    final responseData = json.decode(response.body);
    return responseData['message'] ?? 'Registrasi berhasil';
  }

  Future<void> loginUser(LoginRequest request) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal login: ${response.body}');
    }
    // Jika kamu ingin menyimpan token:
    // final data = json.decode(response.body);
    // final token = data['token'];
    // simpan token ke SharedPreferences kalau mau
  }
}
