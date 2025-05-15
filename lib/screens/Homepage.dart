import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/banner_controller.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/KopiQu_header.dart';
import 'package:kopiqu/widgets/Homepage/kopi_card.dart';
import 'package:kopiqu/widgets/Homepage/search_widget.dart';
import 'package:kopiqu/widgets/Homepage/tag_list.dart';
import 'package:kopiqu/widgets/navbar_bottom.dart';
import 'package:kopiqu/widgets/Homepage/banner_slider.dart'; 

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 0;
  final bannerImages = ['assets/baner1.jpg', 'assets/baner2.jpg'];
  final bannerController = BannerController();

 @override
@override
void initState() {
  super.initState();
  // Memulai auto scroll untuk banner
  bannerController.startAutoScroll(bannerImages, () {
    if (mounted) {
      setState(() {}); 
    }
  });
}


  @override
  void dispose() {
    bannerController.dispose();
    super.dispose();
  }

  void onItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: null,
    body: Column(
      children: [
        const KopiQuHeader(), // Tetap di atas
         const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SearchWidget(), // Juga tetap di atas
        ),
        const SizedBox(height: 16),

        // Scrollable content
        Expanded(
          child: CustomScrollView(
            slivers: [
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
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          ),
        ),
      ],
    ),
    bottomNavigationBar: NavbarBottom(
      selectedIndex: selectedIndex,
      onItemSelected: onItemSelected,
    ),
  );
}
}