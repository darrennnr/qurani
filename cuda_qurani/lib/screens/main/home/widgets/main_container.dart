// lib/screens/main/home/widgets/main_container.dart
// Container utama dengan slide navigation

import 'package:cuda_qurani/screens/main/home/screens/activity_page.dart';
import 'package:cuda_qurani/screens/main/home/screens/completion_page.dart';
import 'package:flutter/material.dart';
import 'package:cuda_qurani/screens/main/home/screens/home_page.dart';
import 'package:cuda_qurani/screens/main/home/screens/surah_list_page.dart';
import 'package:cuda_qurani/screens/main/home/widgets/navigation_bar.dart';

class MainContainer extends StatefulWidget {
  final int initialIndex;

  const MainContainer({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  late PageController _pageController;
  late int _currentIndex;

  // Main pages yang bisa di-slide
  final List<Widget> _pages = const [
    HomePage(),
    SurahListPage(),
    CompletionPage(),
    ActivityPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onMenuTapped(int index) {
    // Animate to page dengan smooth transition
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuAppBar(
        selectedIndex: _currentIndex,
        onMenuTapped: _onMenuTapped,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(), // Smooth scroll physics
        children: _pages,
      ),
    );
  }
}