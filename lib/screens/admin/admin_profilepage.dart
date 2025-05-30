import 'package:flutter/material.dart';
import 'package:kopiqu/services/auth_service.dart';
import 'package:kopiqu/widgets/admin/admin_profileheader.dart'; // Sesuaikan nama file jika berbeda
import 'package:kopiqu/widgets/admin/admin_infotile.dart'; // Sesuaikan nama file jika berbeda
import 'package:kopiqu/widgets/admin/admin_historycard.dart'; // Sesuaikan nama file jika berbeda
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
  String? avatarUrl; // Jika Anda menyimpan URL avatar di metadata
  String? lastLogin;
  int loginsToday = 0;
  List<Map<String, dynamic>> _dummyLoginHistory = [];

  // Warna dari skema Anda
  final Color headerBackgroundColor = const Color(0xFFD3864A);
  final Color actionButtonColor = const Color(0xFF804E23);
  final Color secondaryTextColor = const Color(0xFFA28C79);
  final Color logoutButtonColor = Colors.red[700]!;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLoginStats(); // Ini masih menggunakan data dummy
  }

  void _loadUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && mounted) {
      setState(() {
        displayName = user.userMetadata?['display_name'] as String? ?? 'Admin';
        email = user.email ?? 'Tidak ada email';
        // Contoh jika Anda menyimpan avatar_url di metadata:
        // avatarUrl = user.userMetadata?['avatar_url'] as String?;
      });
    }
  }

  // TODO: Implementasikan pengambilan data login sebenarnya dari backend Anda
  void _loadLoginStats() {
    if (mounted) {
      final now = DateTime.now();
      final DateFormat timeFormatter = DateFormat('HH:mm', 'id_ID');
      final DateFormat dateFormatter = DateFormat('dd MMM yy', 'id_ID');
      setState(() {
        // Contoh format yang lebih lengkap untuk lastLogin
        lastLogin =
            "${dateFormatter.format(now.subtract(const Duration(minutes: 30)))} ${timeFormatter.format(now.subtract(const Duration(minutes: 30)))}";
        loginsToday = 2; // Data dummy
        _dummyLoginHistory = [
          // Data dummy
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
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar sudah ada di AdminMainScreen, jadi di sini tidak perlu
      body: Column(
        // 1. Gunakan Column sebagai parent utama
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 2. Bagian Header (ProfileHeaderCard) - TIDAK DI DALAM Expanded/ScrollView
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16.0,
              16.0,
              16.0,
              8.0,
            ), // Beri padding agar tidak terlalu mepet
            child: ProfileHeaderCard(
              displayName: displayName,
              email: email,
              avatarUrl: avatarUrl, // Kirim avatarUrl
              backgroundColor: headerBackgroundColor,
              iconColor: Colors.white,
              textColor: Colors.white,
            ),
          ),

          // 3. Bagian Konten yang Bisa Di-scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16.0,
                8.0,
                16.0,
                16.0,
              ), // Padding untuk konten scroll
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bagian Informasi Akun (yang di-uncomment)
                  // Text(
                  //   'Informasi Akun',
                  //   style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black87,
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
                  // Card(
                  //   elevation: 1,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       ProfileInfoTile(
                  //         icon: Icons.edit_outlined,
                  //         title: 'Ubah Detail Profil',
                  //         subtitle: 'Perbarui nama atau informasi kontak Anda',
                  //         iconColor: actionButtonColor,
                  //         onTap: () {
                  //           ScaffoldMessenger.of(context).showSnackBar(
                  //             const SnackBar(
                  //               content: Text(
                  //                 'Fitur Ubah Profil belum diimplementasikan.',
                  //               ),
                  //             ),
                  //           );
                  //         },
                  //       ),
                  //       const Divider(height: 0.5, indent: 16, endIndent: 16),
                  //       ProfileInfoTile(
                  //         icon: Icons.lock_outline,
                  //         title: 'Ubah Password',
                  //         subtitle: 'Ganti password akun admin Anda',
                  //         iconColor: actionButtonColor,
                  //         onTap: () {
                  //           ScaffoldMessenger.of(context).showSnackBar(
                  //             const SnackBar(
                  //               content: Text(
                  //                 'Fitur Ubah Password belum diimplementasikan.',
                  //               ),
                  //             ),
                  //           );
                  //         },
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 10),

                  // Judul Aktivitas Login (yang tidak di-comment)
                  Text(
                    'Aktivitas Login', // Judul ini mungkin bisa masuk ke dalam LoginHistoryCard
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center, // Anda set center di kode Anda, saya biarkan default
                  ),
                  const SizedBox(height: 8),

                  // LoginHistoryCard yang Anda uncomment
                  LoginHistoryCard(
                    loginHistory: _dummyLoginHistory,
                    textColor: const Color(0xFF4E342E),
                    cardBackgroundColor: Colors.white,
                  ),

                  // Card untuk Login Terakhir dan Total Login Hari Ini (yang Anda uncomment)
                  const SizedBox(height: 16),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        children: [
                          if (lastLogin != null)
                            ProfileInfoTile(
                              icon: Icons.history_toggle_off,
                              title: 'Login Terakhir ',
                              subtitle: lastLogin!,
                              iconColor: secondaryTextColor,
                            ),
                          if (lastLogin != null) const Divider(height: 1),
                          ProfileInfoTile(
                            icon: Icons.login_rounded,
                            title: 'Total Login Hari Ini ',
                            subtitle: '$loginsToday kali',
                            iconColor: secondaryTextColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: logoutButtonColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 120,
                          vertical: 15,
                        ), // Kurangi padding horizontal agar tidak terlalu lebar
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () async {
                        final currentContext = context;
                        await AuthService().logout(currentContext);
                        // Navigasi sudah dihandle oleh AuthGate atau listener di AuthService
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
