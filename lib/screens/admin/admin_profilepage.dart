import 'package:flutter/material.dart';
import 'package:kopiqu/services/auth_service.dart';
import 'package:kopiqu/widgets/admin/admin_profileheader.dart';
import 'package:kopiqu/widgets/admin/admin_infotile.dart';
import 'package:kopiqu/widgets/admin/admin_historycard.dart'; // Impor LoginHistoryCard // Pastikan path ini benar
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal di dummy history

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

  final Color headerBackgroundColor = const Color(0xFFD3864A);
  final Color actionButtonColor = const Color(0xFF804E23);
  final Color secondaryTextColor = const Color(0xFFA28C79);
  final Color logoutButtonColor = Colors.red[700]!; // Atau Colors.redAccent

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLoginStats();
  }

  void _loadUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && mounted) {
      setState(() {
        displayName = user.userMetadata?['display_name'] as String? ?? 'Admin';
        email = user.email ?? 'Tidak ada email';
        // avatarUrl = user.userMetadata?['avatar_url'] as String?;
      });
    }
  }

  void _loadLoginStats() {
    if (mounted) {
      final now = DateTime.now();
      final DateFormat timeFormatter = DateFormat('HH:mm');
      setState(() {
        lastLogin =
            "Hari ini, ${timeFormatter.format(now.subtract(const Duration(minutes: 30)))}";
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
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tidak ada AppBar di sini karena AdminMainScreen sudah punya AppBar global
      body: Column(
        // Gunakan Column untuk memisahkan header dan konten scroll
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Bagian Header yang tidak ikut scroll
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16.0,
              16.0,
              16.0,
              0,
            ), // Padding untuk header
            child: ProfileHeaderCard(
              displayName: displayName,
              email: email,
              avatarUrl: avatarUrl,
              backgroundColor: headerBackgroundColor,
              iconColor: Colors.white,
              textColor: Colors.white,
            ),
          ),

          // Bagian Konten yang bisa di-scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                16.0,
              ), // Padding untuk konten scroll
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8), // Jarak dari header ke konten
                  // Text(
                  //   'Informasi Akun',
                  //   style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black87,
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
                  // Card(
                  //   elevation: 2,
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

                  const SizedBox(height: 12),
                  Text(
                    'Aktivitas Login ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  LoginHistoryCard(
                    loginHistory: _dummyLoginHistory,
                    textColor: const Color(
                      0xFF4E342E,
                    ), // Coklat tua untuk teks di history card
                    cardBackgroundColor:
                        Colors.white, // Latar belakang putih untuk history card
                  ),

                  // Anda bisa juga menampilkan Login Terakhir dan Total Login Hari Ini
                  // di dalam Card terpisah atau di bawah LoginHistoryCard jika mau.
                  // Contoh:
                  const SizedBox(height: 16),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                          horizontal: 100,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () async {
                        final currentContext = context;
                        await AuthService().logout(currentContext);
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ), // Padding bawah untuk scrollability
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
