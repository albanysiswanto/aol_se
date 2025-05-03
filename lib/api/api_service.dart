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

  Future<String> inviteChild(String email, String token) async {
    final url = Uri.parse('$baseUrl/api/invite');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'child_email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengundang anak: ${response.body}');
    }

    // final responseData = json.decode(response.body);
    return 'Undangan berhasil dikirim. Silahkan cek email anak anda!';
  }

  Future<String> createQuiz({
    required String token,
    required String title,
    required String description,
  }) async {
    final url = Uri.parse('$baseUrl/quiz/create');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'title': title, 'description': description}),
    );

    if (response.statusCode != 201) {
      throw Exception('Gagal membuat quiz: ${response.body}');
    }

    final data = json.decode(response.body);
    return data['quiz_id'];
  }

  Future<String> addQuestionToQuiz({
    required String token,
    required String quizId,
    required String question,
    required List<String> options,
    required String correctAnswer,
  }) async {
    final url = Uri.parse('$baseUrl/quiz/add-question');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'quiz_id': quizId,
        'question': question,
        'options': options,
        'correct_answer': correctAnswer,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Gagal menambahkan pertanyaan: ${response.body}');
    }

    final data = json.decode(response.body);
    return data['question_id'];
  }

  Future<List<Map<String, dynamic>>> fetchChildren(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/parent/children'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch children: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchChildQuizzes(String token) async {
    final url = Uri.parse('$baseUrl/api/quiz/child');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch child quizzes');
    }
  }

  Future<List<dynamic>> fetchQuizQuestions({
    required String quizId,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/quiz/$quizId/questions');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil soal kuis: ${response.body}');
    }
  }
}
