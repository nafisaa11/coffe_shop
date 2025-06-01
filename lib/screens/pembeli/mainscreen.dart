import 'package:flutter/material.dart';
import 'package:kopiqu/screens/pembeli/Homepage.dart';
import 'package:kopiqu/screens/pembeli/menupage.dart';
import 'package:kopiqu/screens/pembeli/profile_page.dart';
import 'package:kopiqu/widgets/Layout/bottomNavbar_widget.dart';
import 'package:kopiqu/services/cart_ui_service.dart';
import 'package:provider/provider.dart';
import 'package:kopiqu/widgets/Layout/KopiQuAppBar.dart'; // 👈 1. IMPORT WIDGET APPBAR BARU

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 1;
  final GlobalKey _cartIconKey =
      GlobalKey(); // GlobalKey tetap dikelola di sini

  final List<Widget> pages = [
    const MenuPage(),
    const Homepage(),
    const ProfilePage(),
  ];


  void onItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<CartUIService>(
          context,
          listen: false,
        ).registerCartIconKey(_cartIconKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          selectedIndex ==
                  2
              ? null 
              : KopiQuAppBar(
                cartIconKey: _cartIconKey,
              ),
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: NavbarBottom(
        selectedIndex: selectedIndex,
        onItemSelected: onItemSelected,
      ),
    );
  }
}
