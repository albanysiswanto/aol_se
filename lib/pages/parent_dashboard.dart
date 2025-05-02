import 'dart:async';
import 'package:flutter/material.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int? _selectedChildIndex;

  final List<String> adImages = [
    'assets/images/ad1.png',
    'https://via.placeholder.com/400x200?text=Ad+2',
    'https://via.placeholder.com/400x200?text=Ad+3',
  ];

  final List<String> children = [
    'Anak 1',
    'Anak 2',
    // 'Anak 3',
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % adImages.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Child Dashboard"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: adImages.length,
              itemBuilder: (context, index) {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _currentPage == index ? 1.0 : 0.3,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(adImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Daftar Anak:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: children.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final isSelected = _selectedChildIndex == index;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedChildIndex = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple.withOpacity(0.1) : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.person,
                          color: isSelected ? Colors.deepPurple : Colors.grey),
                      title: Text(
                        children[index],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.deepPurple : Colors.black,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.deepPurple)
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
