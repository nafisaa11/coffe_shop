import 'package:flutter/material.dart';

class BannerSlider extends StatelessWidget {
  final PageController pageController;
  final List<String> bannerImages;

  const BannerSlider({
    super.key,
    required this.pageController,
    required this.bannerImages,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: pageController,
        itemCount: bannerImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                bannerImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          );
        },
      ),
    );
  }
}
