// lib/widgets/dialogs/forgot_password_dialog.dart (atau path yang sesuai)
import 'package:flutter/material.dart';
import 'package:kopiqu/services/auth_service.dart';
import 'package:kopiqu/widgets/customtextfield.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:lottie/lottie.dart';

const Color kDialogPrimaryColor = Color(0xFFB06C30); // kCafeMediumBrown
const Color kDialogSecondaryColor = Color(0xFF4D2F15); // kCafeDarkBrown
const Color kDialogBackgroundColor = Color(0xFFF7E9DE); // kCafeVeryLightBeige
const Color kDialogMutedTextColor = Color(0xFF4E342E);

void showForgotPasswordDialog({
  required BuildContext
  context, // Ini adalah context dari halaman/widget pemanggil
  required TextEditingController resetEmailController,
  required VoidCallback onLoadingStart,
  required VoidCallback onLoadingEnd,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      // dialogContext adalah context khusus untuk AlertDialog
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: kDialogBackgroundColor,
        titlePadding: const EdgeInsets.only(top: 24, bottom: 0),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon( // Ikon kunci di-comment sesuai kode Anda
            //   PhosphorIcons.key(PhosphorIconsStyle.duotone),
            //   size: 48,
            //   color: kDialogPrimaryColor,
            // ),
            const SizedBox(
              height: 12,
            ), // Jika ikon di atas tidak ada, SizedBox ini mungkin tidak perlu atau bisa disesuaikan
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
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Lottie.asset(
                'assets/lottie/animation-resetpassword.json',
                height: 150, // Sesuai kode Anda
                width: 400, // Sesuai kode Anda
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 4), // Sesuai kode Anda
              Text(
                'Jangan khawatir! Masukkan email Anda di bawah ini dan kami akan mengirimkan link untuk mereset password Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: kDialogMutedTextColor),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Email Terdaftar',
                hintText: 'contoh@gmail.com',
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
                    final String emailInput = resetEmailController.text.trim();

                    if (emailInput.isEmpty) {
                      // 1. Tutup dialog terlebih dahulu
                      Navigator.of(dialogContext).pop();
                      // 2. Tampilkan SnackBar menggunakan context halaman
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email tidak boleh kosong.'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return; // Hentikan proses
                    }

                    bool isValidEmail = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    ).hasMatch(emailInput);

                    if (!isValidEmail) {
                      // 1. Tutup dialog terlebih dahulu
                      Navigator.of(dialogContext).pop();
                      // 2. Tampilkan SnackBar menggunakan context halaman
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Format email tidak valid.'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return; // Hentikan proses
                    }

                    // Jika email valid dan tidak kosong
                    Navigator.of(
                      dialogContext,
                    ).pop(); // Tutup dialog sebelum proses loading
                    onLoadingStart();
                    try {
                      await AuthService().sendPasswordResetEmail(
                        emailInput, // Gunakan emailInput yang sudah di-trim
                        context, // Context dari halaman pemanggil
                      );
                    } finally {
                      // Pastikan onLoadingEnd selalu dipanggil, bahkan jika ada error
                      onLoadingEnd();
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
