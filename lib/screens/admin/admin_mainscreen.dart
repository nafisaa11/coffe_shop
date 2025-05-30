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

  final List<Widget> _pages = [
    const AdminDashboardContentPage(),
    const AdminProfilePage(),
  ];

  final List<String> _pageTitles = ['Dashboard Admin', 'Profil Admin'];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil warna dari tema. primaryColorDark dijamin ada nilainya.
    final Color appBarColor = Theme.of(context).primaryColorDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        // Langsung gunakan appBarColor dari tema
        backgroundColor: appBarColor,
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: AdminBottomNavbar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}
