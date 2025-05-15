import 'package:flutter/material.dart';
import 'package:kopiqu/models/kopi.dart';
import 'kopi_card.dart';

class KopiGrid extends StatelessWidget {
  const KopiGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
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
    );
  }
}
