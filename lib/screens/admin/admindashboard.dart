// lib/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          'Selamat datang di Dashboard Admin!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}