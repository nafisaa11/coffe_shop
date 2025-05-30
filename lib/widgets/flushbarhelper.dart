// widgets/flushbarhelper.dart (atau path yang sesuai)
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart'; // Pastikan Anda sudah import ini

class FlushbarHelper {
  // Konstanta yang sudah Anda definisikan
  static const Duration defaultFlushbarDuration = Duration(
    seconds: 3,
  ); // Mengganti nama agar lebih jelas sebagai default
  static const Duration flushbarAnimDuration = Duration(milliseconds: 500);
  static const EdgeInsets flushbarMargin = EdgeInsets.all(8);
  static const double flushbarRadius = 8.0;

  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title, // Tambahkan title sebagai parameter opsional
    required Color backgroundColor,
    required IconData icon,
    Duration? duration, // 👈 1. TAMBAHKAN PARAMETER DURATION DI SINI (opsional)
  }) async {
    // Pastikan context masih valid sebelum menampilkan Flushbar, terutama setelah operasi async
    if (!context.mounted) return;

    await Flushbar(
      title: title, // Gunakan title jika ada
      message: message,
      backgroundColor: backgroundColor,
      // 👇 2. GUNAKAN PARAMETER DURATION YANG DITERIMA ATAU DEFAULT DARI KONSTANTA
      duration: duration ?? defaultFlushbarDuration,
      flushbarPosition: FlushbarPosition.TOP,
      margin: flushbarMargin,
      borderRadius: BorderRadius.circular(flushbarRadius),
      icon: Icon(
        icon,
        color: Colors.white,
        size: 28.0,
      ), // Sesuaikan size jika perlu
      animationDuration: flushbarAnimDuration,
      // Tambahkan properti lain jika perlu untuk konsistensi tampilan
      titleColor: Colors.white, // Contoh warna title
      messageColor: Colors.white, // Contoh warna message
      padding: const EdgeInsets.all(16), // Contoh padding internal
    ).show(context);
  }
}
