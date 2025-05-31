// lib/widgets/admin/admin_logoutbutton.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/admin/admin_profilecolor.dart';
import 'package:kopiqu/services/auth_service.dart'; // Diperlukan untuk aksi logout
import 'package:lottie/lottie.dart'; // Diperlukan untuk animasi
import 'package:phosphor_flutter/phosphor_flutter.dart'; // Opsional, untuk ikon yang konsisten

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key /*, this.onLogoutCompleted */});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminProfileColors.dangerColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        // Mengganti ikon Material dengan Phosphor Icon untuk konsistensi
        icon: Icon(PhosphorIcons.signOut(PhosphorIconsStyle.bold), color: Colors.white, size: 22),
        label: const Text(
          'Keluar', // Label tombol tetap 'Keluar' sesuai kode Anda
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminProfileColors.dangerColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () async { // Jadikan onPressed async
          // Logika dialog dari _handleLogout dipindahkan ke sini
          final bool? confirmLogout = await showDialog<bool>(
            context: context, // Gunakan BuildContext dari LogoutButton
            barrierDismissible: false,
            builder: (BuildContext dialogContext) { // Ini context baru untuk dialog
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Center(
                  child: Text(
                    'Konfirmasi keluar',
                    style: TextStyle(
                      color: AdminProfileColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Lottie.asset(
                      'assets/lottie/animation-logout.json',
                      height: 130, // Sedikit disesuaikan
                      width: 130,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Anda yakin ingin keluar dari akun?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AdminProfileColors.textSecondary, fontSize: 15),
                    ),
                  ],
                ),
                actionsAlignment: MainAxisAlignment.center,
                actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AdminProfileColors.textSecondary,
                            side: BorderSide(color: Colors.grey.shade300), // Border lebih halus
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
                          onPressed: () {
                            Navigator.of(dialogContext).pop(false);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminProfileColors.dangerColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          // Mengkapitalisasi 'Keluar' agar konsisten dengan 'Batal'
                          child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w600)),
                          onPressed: () {
                            Navigator.of(dialogContext).pop(true);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );

          // Jika pengguna mengkonfirmasi logout
          if (confirmLogout == true && context.mounted) {
            // Panggil AuthService.logout menggunakan context dari LogoutButton
            // Pastikan AuthService().logout() bisa menangani navigasi dari context ini
            await AuthService().logout(context);
            // Jika ada callback onLogoutCompleted:
            // onLogoutCompleted?.call();
          }
        },
      ),
    );
  }
}