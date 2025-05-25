import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/screens/mainscreen.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:kopiqu/screens/loginpage.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<void> register(
    String email,
    String password,
    String confirmPassword,
    BuildContext context,
  ) async {
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Flushbar(
        message: 'Semua kolom wajib diisi!',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: const Icon(Icons.error, color: Colors.white),
        animationDuration: const Duration(milliseconds: 500),
      ).show(context);
      return;
    }

    if (password != confirmPassword) {
      Flushbar(
        message: 'Password dan konfirmasi password tidak sama!',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: const Icon(Icons.error, color: Colors.white),
        animationDuration: const Duration(milliseconds: 500),
      ).show(context);
      return;
    }

    try {
      // Ambil nama depan dari email sebelum tanda @
      final displayName = email.split('@')[0];

      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName, // ← simpan ke user_metadata
        },
      );

      final User? user = res.user;

      if (user != null) {
        Flushbar(
          message: 'Registrasi berhasil! Silakan login.',
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(Icons.check_circle, color: Colors.white),
          animationDuration: const Duration(milliseconds: 500),
        ).show(context);

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        });
      }
    } on AuthException catch (e) {
      Flushbar(
        message: e.message,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: const Icon(Icons.error, color: Colors.white),
        animationDuration: const Duration(milliseconds: 500),
      ).show(context);
    } catch (e) {
      Flushbar(
        message: e.toString(),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: const Icon(Icons.error, color: Colors.white),
        animationDuration: const Duration(milliseconds: 500),
      ).show(context);
    }
  }

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    // Cek kalau masih ada kolom kosong
    if (email.isEmpty || password.isEmpty) {
      Flushbar(
        message: 'Semua kolom wajib diisi!',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: const Icon(Icons.error, color: Colors.white),
        animationDuration: const Duration(milliseconds: 500),
      ).show(context);
      return; // Stop proses login
    }

    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final User? user = res.user;

      if (user != null) {
        Flushbar(
          message: 'Berhasil Masuk.',
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(Icons.check_circle, color: Colors.white),
          animationDuration: const Duration(milliseconds: 500),
        ).show(context);

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        });
      }
    } on AuthException catch (_) {
      // Kalau email/password salah
      Flushbar(
        message: 'Email atau password salah!',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: const Icon(Icons.error, color: Colors.white),
        animationDuration: const Duration(milliseconds: 500),
      ).show(context);
    } catch (e) {
      // Error lain di luar AuthException
      Flushbar(
        message: 'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: const Icon(Icons.error, color: Colors.white),
        animationDuration: const Duration(milliseconds: 500),
      ).show(context);
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await supabase.auth.signOut();

      // Tampilkan notifikasi sukses
      Flushbar(
        message: 'Berhasil logout.',
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: const Icon(Icons.check_circle, color: Colors.white),
        animationDuration: const Duration(milliseconds: 500),
      ).show(context);

      // Delay sebentar biar user lihat flushbar-nya
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      });
    } catch (e) {
      Flushbar(
        message: 'Gagal logout: $e',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: const Icon(Icons.error, color: Colors.white),
        animationDuration: const Duration(milliseconds: 500),
      ).show(context);
    }
  }
}
