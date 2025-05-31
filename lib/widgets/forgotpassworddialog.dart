// lib/widgets/dialogs/forgot_password_dialog.dart (atau path yang sesuai)
import 'package:flutter/material.dart';
import 'package:kopiqu/services/auth_service.dart';
import 'package:kopiqu/widgets/customtextfield.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:lottie/lottie.dart'; // 👈 1. PASTIKAN IMPORT INI ADA DAN TIDAK DI-COMMENT

// Definisikan warna tema jika belum ada di file terpisah yang bisa diakses di sini
const Color kDialogPrimaryColor = Color(0xFFB06C30); // kCafeMediumBrown
const Color kDialogSecondaryColor = Color(0xFF4D2F15); // kCafeDarkBrown
const Color kDialogBackgroundColor = Color(0xFFF7E9DE); // kCafeVeryLightBeige
// const Color kDialogTextColor = Color(0xFF1D1616); // kCafeTextBlack (tidak terpakai langsung di sini)
const Color kDialogMutedTextColor = Color(0xFF4E342E);

void showForgotPasswordDialog({
  required BuildContext context,
  required TextEditingController resetEmailController,
  required VoidCallback onLoadingStart,
  required VoidCallback onLoadingEnd,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: kDialogBackgroundColor,
        titlePadding: const EdgeInsets.only(top: 24, bottom: 0),
        title: Column(
          // Judul tetap di sini, animasi akan di bawahnya di bagian content
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon(
            //   PhosphorIcons.key(PhosphorIconsStyle.duotone),
            //   size: 48,
            //   color: kDialogPrimaryColor,
            // ),
            const SizedBox(height: 12),
            Text(
              'Lupa Password?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kDialogSecondaryColor,
                fontSize: 22,
              ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(
          24,
          16,
          24,
          24,
        ), // Sesuaikan padding atas content
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // --- LOKASI PENAMBAHAN ANIMASI LOTTIE ---
              Lottie.asset(
                'assets/lottie/animation-resetpassword.json', // Path ke file Lottie Anda
                height: 200, // Sesuaikan tinggi animasi
                width: 400, // Sesuaikan lebar animasi
                fit: BoxFit.contain,
              ),
              const SizedBox(
                height: 4,
              ), // Spasi antara animasi dan teks deskripsi
              // --- AKHIR PENAMBAHAN ANIMASI LOTTIE ---
              Text(
                'Jangan khawatir! Masukkan email Anda di bawah ini dan kami akan mengirimkan link untuk mereset password Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: kDialogMutedTextColor),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Email Terdaftar',
                hintText: 'contoh@email.com',
                controller: resetEmailController,
                prefixIcon: PhosphorIcons.envelopeSimple(
                  PhosphorIconsStyle.regular,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kDialogPrimaryColor,
                    side: BorderSide(
                      color: kDialogPrimaryColor.withOpacity(0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Batal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(
                    PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.regular),
                    size: 18,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDialogPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    if (resetEmailController.text.isNotEmpty) {
                      bool isValidEmail = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                      ).hasMatch(resetEmailController.text);

                      if (!isValidEmail) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Format email tidak valid.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      Navigator.of(dialogContext).pop();
                      onLoadingStart();
                      try {
                        await AuthService().sendPasswordResetEmail(
                          resetEmailController.text.trim(),
                          context,
                        );
                      } finally {
                        onLoadingEnd();
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email tidak boleh kosong.'),
                          backgroundColor: Colors.orangeAccent,
                        ),
                      );
                    }
                  },
                  label: const Text(
                    'Kirim Link',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
