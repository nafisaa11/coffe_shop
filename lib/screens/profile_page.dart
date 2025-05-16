import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:kopiqu/widgets/profile_header.dart';
import 'package:kopiqu/screens/loginpage.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ProfileHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(30),
              children: [
                _buildMenuItem(
                  icon: PhosphorIcons.user(),
                  text: 'Profil Saya',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: PhosphorIcons.clockCounterClockwise(),
                  text: 'Riwayat Pembelian',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: PhosphorIcons.signOut(),
                  text: 'Log Out',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(text),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
