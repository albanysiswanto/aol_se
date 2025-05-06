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
    // Tentukan halaman dan item navigasi berdasarkan role
    List<Widget> pages = [
      widget.userRole == 'Parent' ? ParentDashboard() : ChildDashboard(),
      ProfilePage(),
    ];

    List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];

    // Jika role-nya adalah Child, tambahkan halaman dan item Progress
    if (widget.userRole == 'Child') {
      pages.add(ProgressPage());
      navItems.add(
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: 'Progress',
        ),
      );
    }

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: navItems,
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
