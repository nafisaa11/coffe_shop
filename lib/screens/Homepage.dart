import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/banner_controller.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/Homepage/banner_slider.dart';
import 'package:kopiqu/widgets/Homepage/kopi_card.dart';
import 'package:kopiqu/widgets/Homepage/search_widget.dart';
import 'package:kopiqu/widgets/Homepage/tag_list.dart';
import 'package:kopiqu/widgets/KopiQu_header.dart';
import 'package:kopiqu/widgets/navbar_bottom.dart'; // Ganti dari banner_carousel.dart

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 1;
  final bannerImages = ['assets/baner1.jpg', 'assets/baner2.jpg'];
  final bannerController = BannerController();

 @override
@override
void initState() {
  super.initState();
  // Memulai auto scroll untuk banner
  bannerController.startAutoScroll(bannerImages, () {
    if (mounted) {
      setState(() {}); // Memperbarui tampilan setelah animasi selesai
    }
  });
}


  @override
  void dispose() {
    bannerController.dispose();
    super.dispose();
  }

void _onItemSelected(int index) {
  setState(() {
    selectedIndex = index;
  });

  if (index == 0) {
    if (ModalRoute.of(context)!.settings.name != '/menu') {
      Navigator.pushReplacementNamed(context, '/menu');
    }
  } else if (index == 1) {
    if (ModalRoute.of(context)!.settings.name != '/home') {
      Navigator.pushReplacementNamed(context, '/home');
    }
  } else if (index == 2) {
    if (ModalRoute.of(context)!.settings.name != '/profile') {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: CustomScrollView(
              slivers: [
                //search 
                SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SearchWidget(
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

                //banner
                SliverToBoxAdapter(
                  child: BannerSlider( // Ganti dari BannerCarousel
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
