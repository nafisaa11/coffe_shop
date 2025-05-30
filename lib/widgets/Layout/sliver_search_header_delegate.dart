// widgets/Layout/sliver_search_header_delegate.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/Homepage/search_widget.dart'; // Sesuaikan path jika berbeda

class SliverSearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final SearchWidget searchWidget;
  final Color backgroundColor;
  final double height; // Tambahkan parameter tinggi

  SliverSearchHeaderDelegate({
    required this.searchWidget,
    required this.backgroundColor,
    this.height = 70.0, // Default tinggi untuk SearchWidget + padding
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: searchWidget,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverSearchHeaderDelegate oldDelegate) {
    return searchWidget != oldDelegate.searchWidget ||
        backgroundColor != oldDelegate.backgroundColor ||
        height != oldDelegate.height;
  }
}
