import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AdminBottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminBottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  // Helper method untuk membuat item navigasi, mirip dengan punya pembeli
  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = index == selectedIndex;
    return Icon(
      icon,
      size: isSelected ? 32 : 24, // besar saat aktif
      color: isSelected ? Colors.white : Colors.black, // hitam jika tidak aktif
    );
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: selectedIndex,
      onTap: onItemSelected,
      height: 70,
      color: const Color(0xFFD88241),
      backgroundColor: Colors.transparent,
      buttonBackgroundColor: const Color(0xFF804E23),
      animationDuration: const Duration(milliseconds: 300),
      items: [
        _buildNavItem(PhosphorIcons.squaresFour(), 0), // Ikon Dashboard
        _buildNavItem(PhosphorIcons.user(), 1), // Ikon Profil
      ],
    );
  }
}
