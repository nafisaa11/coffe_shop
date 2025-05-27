import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/screens/mainscreen.dart';
import 'package:flutter/material.dart';
import 'package:kopiqu/screens/loginpage.dart';
import 'package:kopiqu/widgets/flushbarhelper.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Validasi isian kosong
  bool _validateFields(List<String> fields, BuildContext context) {
    if (fields.any((field) => field.isEmpty)) {
      FlushbarHelper.show(
        context,
        message: 'Semua kolom wajib diisi!',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
      return false;
    }
    return true;
  }

  Future<void> register(
    String email,
    String password,
    String confirmPassword,
    BuildContext context,
  ) async {
    if (!_validateFields([email, password, confirmPassword], context)) return;
    if (password != confirmPassword) {
      FlushbarHelper.show(
        context,
        message: 'Password dan konfirmasi tidak sama!',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
      return;
    }

    try {
      final displayName = email.split('@')[0];
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );

      if (res.user != null) {
        await FlushbarHelper.show(
          context,
          message: 'Registrasi berhasil! Silakan login.',
          backgroundColor: Colors.green,
          icon: Icons.check_circle,
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
        });
      }
    } on AuthException catch (e) {
      FlushbarHelper.show(
        context,
        message: e.message,
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    } catch (e) {
      FlushbarHelper.show(
        context,
        message: 'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    if (!_validateFields([email, password], context)) return;

    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user != null) {
        await FlushbarHelper.show(
          context,
          message: 'Berhasil Masuk.',
          backgroundColor: Colors.green,
          icon: Icons.check_circle,
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen()),
          );
        });
      }
    } on AuthException {
      FlushbarHelper.show(
        context,
        message: 'Email atau password salah!',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    } catch (e) {
      FlushbarHelper.show(
        context,
        message: 'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      await FlushbarHelper.show(
        context,
        message: 'Berhasil logout.',
        backgroundColor: Colors.green,
        icon: Icons.check_circle,
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
        );
      });
    } catch (e) {
      FlushbarHelper.show(
        context,
        message: 'Gagal logout: $e',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    if (email.isEmpty) {
      FlushbarHelper.show(
        context,
        message: 'Masukkan email terlebih dahulu!',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
      return;
    }

    try {
      await supabase.auth.resetPasswordForEmail(email);
      FlushbarHelper.show(
        context,
        message: 'Link reset password dikirim ke email kamu.',
        backgroundColor: Colors.green,
        icon: Icons.check_circle,
      );
    } catch (e) {
      FlushbarHelper.show(
        context,
        message: 'Gagal kirim reset password: $e',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }

  Future<void> updateEmail(String newEmail, BuildContext context) async {
    try {
      await supabase.auth.updateUser(UserAttributes(email: newEmail));
      FlushbarHelper.show(
        context,
        message: 'Email berhasil diperbarui.',
        backgroundColor: Colors.green,
        icon: Icons.check_circle,
      );
    } catch (e) {
      FlushbarHelper.show(
        context,
        message: 'Gagal update email: $e',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }

  Future<void> updateDisplayName(
    String newDisplayName,
    BuildContext context,
  ) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(data: {'display_name': newDisplayName}),
      );
      FlushbarHelper.show(
        context,
        message: 'Display name berhasil diperbarui.',
        backgroundColor: Colors.green,
        icon: Icons.check_circle,
      );
    } catch (e) {
      FlushbarHelper.show(
        context,
        message: 'Gagal update display name: $e',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }
}
