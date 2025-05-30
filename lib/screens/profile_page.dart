// screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:kopiqu/widgets/Layout/headerProfile_widget.dart'; // Asumsi ini ada dan berfungsi
import 'package:kopiqu/services/auth_service.dart';
import 'package:kopiqu/screens/daftar_riwayat_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ProfileHeader(), // Header profil kustom Anda
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ), // Sedikit penyesuaian padding
              children: [
                _buildMenuItem(
                  context: context,
                  icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
                  text: 'Profil Saya',
                  onTap: () {
                    print('Profil Saya di-tap');
                    // TODO: Navigasi ke halaman edit profil
                  },
                ),
                const SizedBox(height: 8),
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
                const SizedBox(
                  height: 24,
                ), // Beri spasi lebih sebelum tombol logout
                // Tombol Log Out yang lebih menonjol
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ), // Padding agar tidak terlalu mepet
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
                      backgroundColor:
                          Colors
                              .redAccent
                              .shade700, // Warna merah untuk aksi logout
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Bentuk tombol
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
                // Alternatif lain: ListTile dengan style berbeda (jika ingin tetap seperti list item)
                // ListTile(
                //   leading: Icon(PhosphorIcons.signOut(PhosphorIconsStyle.regular), color: Colors.red.shade700, size: 24),
                //   title: Text(
                //     'Log Out',
                //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red.shade700),
                //   ),
                //   trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red.shade400),
                //   onTap: () {
                //     AuthService().logout(context);
                //   },
                //   contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                //   tileColor: Colors.red.withOpacity(0.05), // Sedikit background
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(10.0),
                //     side: BorderSide(color: Colors.red.shade100)
                //   ),
                // ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // _buildMenuItem tetap sama untuk item menu lainnya
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    // Mengembalikan ke versi Anda dengan sedikit penyesuaian jika Card tidak diinginkan
    // Jika Anda ingin Card seperti sebelumnya, uncomment bagian Card di bawah.
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
        side: BorderSide(
          color: Colors.grey.shade300,
        ), // Tambahkan border halus agar terlihat seperti Card
      ),
      tileColor: Colors.white, // Beri background putih agar border terlihat
    );
    // Jika Anda lebih suka versi Card:
    /*
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.brown.shade600, size: 24),
        title: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade600,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
    */
  }
}
