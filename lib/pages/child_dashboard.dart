import 'package:flutter/material.dart';
import 'package:lapar_fe/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/quiz_page.dart';
import '../widgets/widget_photo.dart';

class ChildDashboard extends StatefulWidget {
  const ChildDashboard({super.key});

  @override
  State<ChildDashboard> createState() => _ChildDashboardState();
}

class _ChildDashboardState extends State<ChildDashboard> {
  List<dynamic> _quizzes = [];
  bool _isLoading = true;
  final Map<String, bool> _isExpanded = {};

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception("Token tidak ditemukan.");
      }

      final quizzes = await ApiService(
        baseUrl: "http://localhost:2020",
      ).fetchChildQuizzes(token);

      if (quizzes != null && quizzes.isNotEmpty) {
        setState(() {
          _quizzes = quizzes;
          _isLoading = false;
        });
      } else {
        print("No quizzes available");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching quizzes: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _shorten(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Child Dashboard"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: const BannerSlider(),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child:
                          _quizzes.isEmpty
                              ? const Center(
                                child: Text("No quizzes available."),
                              )
                              : GridView.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 3 / 2,
                                children:
                                    _quizzes.map((quiz) {
                                      final quizId = quiz['id'];
                                      final isExpanded =
                                          _isExpanded[quizId] ?? false;
                                      final description =
                                          quiz['description'] ?? '';
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      QuizPage(quizId: quizId),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  quiz['title'] ?? 'Untitled',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Expanded(
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          isExpanded
                                                              ? description
                                                              : _shorten(
                                                                description,
                                                                60,
                                                              ),
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                        if (description.length >
                                                            60)
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                _isExpanded[quizId] =
                                                                    !isExpanded;
                                                              });
                                                            },
                                                            child: Text(
                                                              isExpanded
                                                                  ? 'Sembunyikan'
                                                                  : 'Selengkapnya',
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        Colors
                                                                            .blue,
                                                                  ),
                                                            ),
                                                          ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        Text(
                                                          "Reward: ${quiz['reward'] ?? '-'} poin",
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors
                                                                        .green,
                                                              ),
                                                        ),
                                                        Text(
                                                          "Timer: ${quiz['timer'] ?? '-'} menit",
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors
                                                                        .orange,
                                                              ),
                                                        ),
                                                        Text(
                                                          "By ${quiz['parent_name'] ?? 'Unknown'}",
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 11,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Screen Time Remaining:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '45 mins',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
