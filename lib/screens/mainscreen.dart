import 'package:flutter/material.dart';
import 'package:kopiqu/screens/Homepage.dart';
import 'package:kopiqu/screens/menupage.dart';
import 'package:kopiqu/screens/profile_page.dart';
import 'package:kopiqu/widgets/navbar_bottom.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 1;

  final List<Widget> pages = const [
    MenuPage(),
    Homepage(),
    ProfilePage(),
  ];

  void onItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavbarBottom(
        selectedIndex: selectedIndex,
        onItemSelected: onItemSelected,
      ),
    );
  }
}
