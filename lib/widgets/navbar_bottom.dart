import 'package:flutter/material.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class NavbarBottom extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const NavbarBottom({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return WaterDropNavBar(
      backgroundColor: const Color(0xFD3864A), 
      waterDropColor: const Color(0xFF804E23), 
      selectedIndex: selectedIndex,
      onItemSelected: onItemSelected,
      barItems:  [
        BarItem(
          filledIcon: Icons.home_rounded,
          outlinedIcon: Icons.home_outlined,
        ),
        BarItem(
          filledIcon: Icons.favorite_rounded,
          outlinedIcon: Icons.favorite_border_rounded,
        ),
      ],
    );
  }
}
