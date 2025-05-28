import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/screens/mainscreen.dart'; // Pastikan import ini benar
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

    // Validasi email untuk pembeli (opsional, jika ingin membatasi domain)
    if (!email.endsWith('@gmail.com')) {
      // Contoh jika ingin membatasi
      FlushbarHelper.show(
        context,
        message: 'Untuk pembeli,diharap menggunakan email google aktif',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );

      return;
    }

    try {
      final displayName = email.split('@')[0];
      // Menetapkan peran 'pembeli' saat registrasi
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName, 'role': 'pembeli'},
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
        // Mengambil role dari user_metadata
        final userRole = res.user?.userMetadata?['role'] as String?;

        // Debugging: Cetak role pengguna ke konsol
        print('User role: $userRole');

        await FlushbarHelper.show(
          context,
          message: 'Berhasil Masuk.',
          backgroundColor: Colors.green,
          icon: Icons.check_circle,
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (userRole == 'admin' && email.endsWith('@kopiqu.com')) {
            // Arahkan ke halaman admin jika role adalah 'admin' dan email sesuai
            Navigator.pushReplacementNamed(context, '/admin');
          } else if (userRole == 'pembeli') {
            // Arahkan ke halaman pembeli jika role adalah 'pembeli'
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MainScreen(),
              ), // Pastikan MainScreen adalah halaman untuk pembeli
            );
          } else {
            // Jika role tidak dikenali atau email admin tidak sesuai
            FlushbarHelper.show(
              context,
              message: 'Email address atau role tidak sesuai.',
              backgroundColor: Colors.orange,
              icon: Icons.warning,
            );
            // Logout pengguna jika role tidak sesuai untuk mencegah akses tidak sah
            Future.delayed(const Duration(seconds: 2), () async {
              await supabase.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
              );
            });
          }
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

  Future<void> sendPasswordResetEmail(
    String email,
    BuildContext context,
  ) async {
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
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.kopiqu://login-callback/',
      );
      FlushbarHelper.show(
        context,
        message:
            'Link reset password telah dikirim ke email Anda. Silakan cek email.',
        backgroundColor: Colors.green,
        icon: Icons.check_circle,
      );
    } on AuthException catch (e) {
      FlushbarHelper.show(
        context,
        message: 'Gagal mengirim link reset: ${e.message}',
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

  Future<void> updateUserPassword(
    BuildContext context,
    String newPassword,
    String confirmNewPassword,
  ) async {
    if (!_validateFields([newPassword, confirmNewPassword], context)) return;

    if (newPassword != confirmNewPassword) {
      FlushbarHelper.show(
        context,
        message: 'Password baru dan konfirmasi tidak sama!',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
      return;
    }
    if (newPassword.length < 6) {
      FlushbarHelper.show(
        context,
        message: 'Password minimal 6 karakter!',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
      return;
    }

    try {
      if (supabase.auth.currentUser == null) {
        FlushbarHelper.show(
          context,
          message: 'Sesi tidak valid. Silakan coba lagi dari link email.',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => LoginPage()),
            (route) => false,
          );
        });
        return;
      }

      await supabase.auth.updateUser(UserAttributes(password: newPassword));

      await FlushbarHelper.show(
        context,
        message:
            'Password berhasil diperbarui! Silakan login dengan password baru Anda.',
        backgroundColor: Colors.green,
        icon: Icons.check_circle,
      );
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
        );
      });
    } on AuthException catch (e) {
      FlushbarHelper.show(
        context,
        message: 'Gagal memperbarui password: ${e.message}',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    } catch (e) {
      FlushbarHelper.show(
        context,
        message: 'Terjadi kesalahan saat memperbarui password: $e',
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
      // Anda bisa juga menyimpan role di sini jika diperlukan saat update,
      // tapi biasanya role di-set saat pembuatan user.
      final currentUserRole = supabase.auth.currentUser?.userMetadata?['role'];
      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'display_name': newDisplayName,
            'role': currentUserRole, // jika ingin memastikan role tetap ada
          },
        ),
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
