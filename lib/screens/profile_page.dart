// screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:kopiqu/widgets/Layout/headerProfile_widget.dart';
import 'package:kopiqu/screens/daftar_riwayat_page.dart';
import 'package:kopiqu/screens/editprofiledialog.dart';
import 'package:kopiqu/widgets/admin/admin_logoutbutton.dart'; // Nama file komponen LogoutButton Anda

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _refreshProfileHeader() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ProfileHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              children: [
                _buildMenuItem(
                  context: context,
                  icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
                  text: 'Profil Saya',
                  onTap: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return const EditProfileDialog();
                      },
                    );
                    if (result == true && mounted) {
                      print(
                        'Profil berhasil diupdate, me-refresh ProfileHeader...',
                      );
                      _refreshProfileHeader();
                    }
                  },
                ),
                const SizedBox(height: 14),
                _buildMenuItem(
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
                const SizedBox(height: 240),
                // Cukup panggil const LogoutButton()
                const LogoutButton(),
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
    return ListTile(
      leading: Icon(icon, color: Colors.brown.shade600, size: 24),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(
        // Anda juga bisa mengganti ikon ini ke Phosphor jika ingin konsisten sepenuhnya
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
