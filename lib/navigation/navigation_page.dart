import 'package:flutter/material.dart';
import '../pages/parent_dashboard.dart';
import '../pages/child_dashboard.dart';
import '../pages/profile_page.dart';
import '../pages/progress_page.dart';
// import '../pages/home_page.dart';

class NavigationPage extends StatefulWidget {
  final String userRole;

  const NavigationPage({super.key, required this.userRole});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Pilih halaman Home berdasarkan role
    final List<Widget> _pages = [
      widget.userRole == 'Parent' ? ParentDashboard() : ChildDashboard(),
      ProfilePage(),
      ProgressPage(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progress'),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
