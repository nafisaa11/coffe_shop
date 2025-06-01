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
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AdminProfileColors.dangerColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(
          PhosphorIcons.signOut(PhosphorIconsStyle.bold),
          color: AdminProfileColors.dangerColor,
          size: 22,
        ),
        label: const Text(
          'Keluar',
          style: TextStyle(
            color: AdminProfileColors.dangerColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          // Warna background ElevatedButton utama, biarkan atau sesuaikan jika perlu
          backgroundColor: const Color.fromARGB(255, 255, 251, 251),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AdminProfileColors.dangerColor, width: 1.5),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () async {
          final bool? confirmLogout = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                // TAMBAHKAN WARNA BACKGROUND ALERT DI SINI
                backgroundColor: const Color(
                  0xFFFFFAF0,
                ), // atau const Color.fromARGB(255, 255, 250, 240)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
                      height: 130,
                      width: 130,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Anda yakin ingin keluar dari akun?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AdminProfileColors.textSecondary,
                        fontSize: 15,
                      ),
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
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Keluar',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop(
                              true,
                            ); // Mengembalikan true saat keluar dikonfirmasi
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );

          if (confirmLogout == true && context.mounted) {
            await AuthService().logout(context);
            // onLogoutCompleted?.call();
          }
        },
      ),
    );
  }
}
