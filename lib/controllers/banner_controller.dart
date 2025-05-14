import 'package:flutter/material.dart';

class BannerController {
  final PageController pageController = PageController(initialPage: 0);
  int currentPage = 0;

  void startAutoScroll(List<String> bannerImages, VoidCallback update) {
    Future.delayed(const Duration(seconds: 3), () {
      if (pageController.hasClients) {
        currentPage = (currentPage + 1) % bannerImages.length;
        pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        update(); // callback untuk trigger scroll berikutnya
        startAutoScroll(bannerImages, update); // Recurse to keep scrolling
      }
    });
  }

  void dispose() {
    pageController.dispose();
  }
}

