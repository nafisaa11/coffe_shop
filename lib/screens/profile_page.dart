// screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:kopiqu/widgets/Layout/headerProfile_widget.dart';
import 'package:kopiqu/services/auth_service.dart';
import 'package:kopiqu/screens/daftar_riwayat_page.dart';
import 'package:kopiqu/screens/editprofiledialog.dart'; // 👈 1. IMPORT EditProfileDialog

class ProfilePage extends StatefulWidget {
  // 👈 2. UBAH MENJADI STATEFULWIDGET
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 👈 2. BUAT CLASS STATE

  // Method untuk refresh UI ProfileHeader setelah update
  // Ini akan memicu ProfileHeader (jika ia StatefulWidget dan membaca user dari Supabase di initState/didChangeDependencies)
  // atau jika ProfileHeader membaca state yang dikelola oleh Provider yang diupdate.
  // Cara paling sederhana adalah membuat ProfilePage menjadi StatefulWidget dan memanggil setState.
  void _refreshProfileHeader() {
    setState(() {
      // Ini akan memaksa ProfileHeader untuk rebuild dan mengambil data user terbaru jika
      // ProfileHeader mengambil data pengguna di build methodnya atau didChangeDependencies.
      // Jika ProfileHeader juga StatefulWidget dan mengambil data di initState,
      // Anda mungkin perlu cara yang lebih canggih untuk memberitahunya agar refresh.
      // Untuk sekarang, kita asumsikan ProfileHeader akan rebuild dengan benar.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ProfileHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                _buildMenuItem(
                  context: context,
                  icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
                  text: 'Profil Saya',
                  onTap: () async {
                    // 👈 3. JADIKAN ASYNC
                    print('Profil Saya di-tap, membuka EditProfileDialog');
                    // Tampilkan dialog dan tunggu hasilnya (jika ada)
                    final result = await showDialog<bool>(
                      // Tunggu hasil boolean
                      context: context,
                      builder: (BuildContext context) {
                        return const EditProfileDialog();
                      },
                    );

                    // Jika dialog ditutup dengan hasil 'true' (artinya ada perubahan yang disimpan)
                    if (result == true) {
                      print(
                        'Profil berhasil diupdate, me-refresh ProfileHeader...',
                      );
                      _refreshProfileHeader(); // Refresh header
                    }
                  },
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  // ... (Riwayat Pembelian tetap sama) ...
                  context: context,
                  icon: PhosphorIcons.clockCounterClockwise(
                    PhosphorIconsStyle.regular,
                  ),
                  text: 'Riwayat Pembelian',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DaftarRiwayatPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Padding(
                  // ... (Tombol Log Out tetap sama) ...
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ElevatedButton.icon(
                    icon: Icon(
                      PhosphorIcons.signOut(PhosphorIconsStyle.regular),
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      AuthService().logout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    // ... (kode _buildMenuItem Anda tetap sama) ...
    return ListTile(
      leading: Icon(icon, color: Colors.brown.shade600, size: 24),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade600,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      tileColor: Colors.white,
    );
  }
}
