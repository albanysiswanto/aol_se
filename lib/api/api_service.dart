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

  Future<Map<String, dynamic>> loginUser(LoginRequest request) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal login: ${response.body}');
    }

    final data = json.decode(response.body);
    final token = data['token'];

    // Decode JWT untuk mendapatkan role
    final payload = _decodeJWT(token);
    final role = payload['role'];

    return {'token': token, 'role': role};
  }

  // Helper decode JWT
  Map<String, dynamic> _decodeJWT(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception("Invalid JWT");
    }

    final payload = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(payload));
    return json.decode(decoded);
  }
}
