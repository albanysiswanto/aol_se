import 'package:flutter/material.dart';
import 'package:lapar_fe/pages/add_child.dart';
import 'package:lapar_fe/pages/add_quiz.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void _toggleFAB() {
    setState(() {
      _isOpen = !_isOpen;
      _isOpen ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ScaleTransition(
      scale: _animation,
      child: Column(
        children: [
          FloatingActionButton.small(
            heroTag: label,
            onPressed: onPressed,
            child: Icon(icon),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Orang Tua')),
      body: const Center(child: Text('Konten dashboard di sini...')),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
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
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animation,
            ),
          ),
        ],
      ),
    );
  }
}
