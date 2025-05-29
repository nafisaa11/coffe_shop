// screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:kopiqu/widgets/Layout/headerProfile_widget.dart';
import 'package:kopiqu/services/auth_service.dart';
import 'package:kopiqu/screens/daftar_riwayat_page.dart'; // 👈 1. IMPORT HALAMAN DAFTAR RIWAYAT

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ProfileHeader(), // Pastikan widget ini ada dan berfungsi
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(30),
              children: [
                _buildMenuItem(
                  context:
                      context, // Tambahkan context jika _buildMenuItem membutuhkannya untuk navigasi
                  icon: PhosphorIcons.user(),
                  text: 'Profil Saya',
                  onTap: () {
                    // Navigasi ke halaman edit profil jika ada
                    print('Profil Saya di-tap');
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: PhosphorIcons.clockCounterClockwise(),
                  text: 'Riwayat Pembelian',
                  onTap: () {
                    // 👇 2. NAVIGASI KE HALAMAN DAFTAR RIWAYAT
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DaftarRiwayatPage(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: PhosphorIcons.signOut(),
                  text: 'Log Out',
                  onTap: () {
                    AuthService().logout(
                      context,
                    ); // Pastikan AuthService dan method logout ada
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Sedikit modifikasi untuk bisa menerima context jika diperlukan
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 22),
      title: Text(text, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
    );
  }
}
