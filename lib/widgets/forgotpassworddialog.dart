import 'package:flutter/material.dart';
import 'package:kopiqu/services/auth_service.dart';
import 'package:kopiqu/widgets/customtextfield.dart';

void showForgotPasswordDialog({
  required BuildContext context,
  required TextEditingController resetEmailController,
  required VoidCallback onLoadingStart,
  required VoidCallback onLoadingEnd,
}) {
  resetEmailController.text = resetEmailController.text;
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Lupa Password', textAlign: TextAlign.center),
        content: CustomTextField(
          label: 'Email',
          hintText: 'Masukkan email terdaftar',
          controller: resetEmailController,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF8D6E63)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8D6E63),
            ),
            onPressed: () async {
              if (resetEmailController.text.isNotEmpty) {
                Navigator.of(dialogContext).pop();
                onLoadingStart();
                await AuthService().sendPasswordResetEmail(
                  resetEmailController.text,
                  context,
                );
                onLoadingEnd();
              }
            },
            child: const Text(
              'Kirim Link Reset',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}
