import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/banner_controller.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/KopiQu_header.dart';
import 'package:kopiqu/widgets/kopi_card.dart';
import 'package:kopiqu/widgets/search_widget.dart';
import 'package:kopiqu/widgets/tag_list.dart';
import 'package:kopiqu/widgets/banner_slider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final bannerImages = ['assets/baner1.jpg', 'assets/baner2.jpg'];
  final bannerController = BannerController();

  @override
  void initState() {
    super.initState();
    bannerController.startAutoScroll(bannerImages, () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SearchWidget(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: BannerSlider(
                    bannerImages: bannerImages,
                    pageController: bannerController.pageController,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                const SliverToBoxAdapter(child: TagList()),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return CoffeeCard(kopi: kopiList[index]);
                      },
                      childCount: kopiList.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: KopiQuHeader(),
          ),
        ],
      ),
    );
  }
}
