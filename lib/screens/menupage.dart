import 'package:flutter/material.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/KopiQu_header.dart';
import 'package:kopiqu/widgets/Homepage/kopi_card.dart';
import 'package:kopiqu/widgets/Homepage/search_widget.dart';
import 'package:kopiqu/widgets/Homepage/tag_list.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

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
