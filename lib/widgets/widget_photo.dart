import 'dart:async';
import 'package:flutter/material.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int _currentIndex = 0;
  late Timer _timer;

  final List<String> _bannerImages = [
    'assets/image/1.png',
    'assets/image/2.png',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _bannerImages.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Image.asset(
          _bannerImages[_currentIndex],
          key: ValueKey<int>(_currentIndex),
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}
