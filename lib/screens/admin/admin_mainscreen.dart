// lib/screens/admin/admin_main_screen.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/screens/admin/admin_dashboard_contentpage.dart';
import 'package:kopiqu/screens/admin/admin_profilepage.dart';
import 'package:kopiqu/widgets/admin/admin_bottom_navbar.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;
  // late PageController _pageController; // HAPUS INI

  final List<Widget> _pages = [ // Daftarkan halaman Anda di sini
    const AdminDashboardContentPage(),
    const AdminProfilePage(),
  ];

  final List<String> _pageTitles = [
    'Dashboard Admin',
    'Profil Admin',
  ];

  // initState dan dispose untuk PageController tidak diperlukan lagi
  // @override
  // void initState() {
  //   super.initState();
  //   _pageController = PageController(initialPage: _selectedIndex);
  // }

  // @override
  // void dispose() {
  //   _pageController.dispose();
  //   super.dispose();
  // }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        backgroundColor: Theme.of(context).primaryColorDark ?? Colors.brown[700],
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack( // GUNAKAN IndexedStack di sini
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: AdminBottomNavbar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
        // pageController: _pageController, // HAPUS INI
      ),
    );
  }
}