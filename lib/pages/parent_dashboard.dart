import 'package:flutter/material.dart';
import 'package:lapar_fe/pages/add_child.dart';
import 'package:lapar_fe/pages/add_quiz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardPageState();
}

class _ParentDashboardPageState extends State<ParentDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isOpen = false;

  List<Map<String, dynamic>> _children = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception("Token tidak ditemukan.");
      }

      final children = await ApiService(
        baseUrl: 'http://localhost:2020',
      ).fetchChildren(token);

      setState(() {
        _children = children;
      });
    } catch (e) {
      debugPrint("Error fetching children: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data anak: $e")));
    }
  }

  void _toggleFAB() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ScaleTransition(
        scale: _animation,
        child: FloatingActionButton.extended(
          heroTag: label,
          onPressed: onPressed,
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
          icon: Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Parent Dashboard")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _children.length,
        itemBuilder: (context, index) {
          final child = _children[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(child['name'] ?? ''),
              subtitle: Text("${child['birth_date'] ?? 'N/A'}"),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Tambahkan menu aksi jika diperlukan
                },
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0, right: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_isOpen)
              _buildOption(
                icon: Icons.person_add,
                label: "Add Child",
                onPressed: () {
                  _toggleFAB();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddChildPage()),
                  );
                },
              ),
            if (_isOpen)
              _buildOption(
                icon: Icons.quiz,
                label: "Add Quiz",
                onPressed: () {
                  _toggleFAB();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddQuizPage()),
                  );
                },
              ),
            FloatingActionButton(
              onPressed: _toggleFAB,
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _animation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
