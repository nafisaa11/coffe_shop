import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:kopiqu/widgets/navbar_bottom.dart';
import 'package:kopiqu/widgets/profile_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedIndex = 2;

  void onItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });

    if (index == 0 && ModalRoute.of(context)!.settings.name != '/menu') {
      Navigator.pushReplacementNamed(context, '/menu');
    } else if (index == 1 && ModalRoute.of(context)!.settings.name != '/home') {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 2 &&
        ModalRoute.of(context)!.settings.name != '/profile') {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

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
                  onTap: () {
                    // TODO: Navigasi ke halaman profil
                  },
                ),
                _buildMenuItem(
                  icon: PhosphorIcons.clockCounterClockwise(),
                  text: 'Riwayat Pembelian',
                  onTap: () {
                    // TODO: Navigasi ke riwayat
                  },
                ),
                _buildMenuItem(
                  icon: PhosphorIcons.signOut(),
                  text: 'Log Out',
                  onTap: () {
                    // TODO: Logout logic
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavbarBottom(
        selectedIndex: selectedIndex,
        onItemSelected: onItemSelected,
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
