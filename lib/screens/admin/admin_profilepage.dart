// lib/pages/admin/admin_profile_page.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/admin/admin_profileheader.dart';
import 'package:kopiqu/widgets/admin/admin_infotile.dart'; // Akan berisi AdminQuickStatsSection
import 'package:kopiqu/widgets/admin/admin_historycard.dart';
import 'package:kopiqu/widgets/admin/admin_logoutbutton.dart';
import 'package:kopiqu/widgets/admin/admin_profilecolor.dart'; // Warna terpusat
import 'package:kopiqu/widgets/admin/admin_sectionheader.dart'; // Widget SectionHeader opsional
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  String displayName = 'Admin';
  String email = 'Tidak ada email';
  String? avatarUrl;
  String? lastLogin;
  int loginsToday = 0;
  List<Map<String, dynamic>> _dummyLoginHistory = [];

  // Warna latar belakang utama halaman diambil dari AdminProfileColors
  final Color backgroundColor = AdminProfileColors.backgroundColor;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLoginStats();
  }

  // Fungsi untuk memuat data pengguna dari Supabase
  void _loadUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && mounted) {
      // mounted check untuk memastikan widget masih ada di tree
      setState(() {
        displayName = user.userMetadata?['display_name'] as String? ?? 'Admin';
        email = user.email ?? 'Tidak ada email';
        // Asumsi avatar_url ada di user_metadata, sesuaikan jika berbeda
        avatarUrl = user.userMetadata?['avatar_url'] as String?;
      });
    }
  }

  // Fungsi untuk memuat statistik login (dummy data)
  void _loadLoginStats() {
    if (mounted) {
      final now = DateTime.now();
      final DateFormat timeFormatter = DateFormat('HH:mm', 'id_ID');
      final DateFormat dateFormatter = DateFormat('dd MMM yy', 'id_ID');
      setState(() {
        lastLogin =
            "${dateFormatter.format(now.subtract(const Duration(minutes: 30)))} ${timeFormatter.format(now.subtract(const Duration(minutes: 30)))}";
        loginsToday = 2;
        _dummyLoginHistory = [
          {
            'timestamp': now.subtract(const Duration(minutes: 30)),
            'device': 'KopiQu Admin Web',
          },
          {
            'timestamp': now.subtract(const Duration(hours: 4)),
            'device': 'Perangkat Tidak Dikenal',
          },
          {
            'timestamp': now.subtract(const Duration(days: 1, hours: 2)),
            'device': 'KopiQu Admin Web',
          },
          {
            // Menambahkan satu item lagi agar tombol "Lihat Semua Riwayat" muncul
            'timestamp': now.subtract(const Duration(days: 2, hours: 1)),
            'device': 'KopiQu Admin Web',
          },
        ];
      });
    }
  }

  // Fungsi untuk navigasi ke halaman riwayat login lengkap
  void _navigateToFullHistory() {
    // TODO: Implementasikan navigasi ke halaman riwayat login lengkap
    _showFeatureNotImplemented(); // Tampilkan pesan bahwa fitur belum ada
  }

  // Menampilkan Snackbar bahwa fitur belum diimplementasikan
  void _showFeatureNotImplemented() {
    if (!mounted) return; // Cek jika widget masih mounted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12),
            Text('Fitur ini belum diimplementasikan.'),
          ],
        ),
        backgroundColor: AdminProfileColors.primaryColor,
        behavior: SnackBarBehavior.floating, // Snackbar mengambang
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        // Menggunakan CustomScrollView untuk efek header yang menarik
        slivers: [
          // Bagian Header Profil
          SliverToBoxAdapter(
            child: AdminProfileHeader(
              displayName: displayName,
              email: email,
              avatarUrl: avatarUrl,
            ),
          ),
          // Bagian Konten Utama
          SliverToBoxAdapter(
            child: Transform.translate(
              // Memberikan efek tumpukan/overlap
              offset: const Offset(0, -20),
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor, // Warna latar belakang konten
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    30,
                    20,
                    20,
                  ), // Padding disesuaikan
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Widget untuk Statistik Cepat (dari admin_infotile.dart)
                      AdminQuickStatsSection(
                        lastLogin: lastLogin,
                        loginsToday: loginsToday,
                      ),
                      const SizedBox(height: 30),

                      // Judul bagian Aktivitas Login
                      const SectionHeader(title: 'Aktivitas Login'),
                      const SizedBox(height: 16),

                      // Widget untuk Kartu Riwayat Login
                      AdminHistoryCard(
                        loginHistory: _dummyLoginHistory,
                        onViewAllPressed: _navigateToFullHistory,
                      ),
                      const SizedBox(height: 40),

                      // Widget untuk Tombol Logout
                      const LogoutButton(),
                      const SizedBox(height: 20), // Padding bawah
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
