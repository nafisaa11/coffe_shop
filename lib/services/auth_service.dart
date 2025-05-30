// services/auth_service.dart
import 'dart:io'; // 👈 1. IMPORT 'dart:io' untuk File
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/screens/mainscreen.dart'; // Pastikan import ini benar
import 'package:kopiqu/screens/loginpage.dart'; // Pastikan import ini benar
import 'package:kopiqu/widgets/flushbarhelper.dart'; // Pastikan path ini benar

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

  // ... (method register, login, logout, sendPasswordResetEmail, updateUserPassword tetap sama seperti yang Anda berikan) ...
  // Pastikan method-method ini sudah berfungsi sesuai harapan Anda.
  // Saya tidak akan mengubahnya kecuali ada yang terkait langsung dengan update profil.

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
    if (!email.endsWith('@gmail.com')) {
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
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName, 'role': 'pembeli'},
      );
      if (res.user != null && context.mounted) {
        await FlushbarHelper.show(
          context,
          message: 'Registrasi berhasil! Silakan login.',
          backgroundColor: Colors.green,
          icon: Icons.check_circle,
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
        });
      }
    } on AuthException catch (e) {
      if (context.mounted)
        FlushbarHelper.show(
          context,
          message: e.message,
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
    } catch (e) {
      if (context.mounted)
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
      if (res.user != null && context.mounted) {
        final userRole = res.user?.userMetadata?['role'] as String?;
        print('User role: $userRole');
        await FlushbarHelper.show(
          context,
          message: 'Berhasil Masuk.',
          backgroundColor: Colors.green,
          icon: Icons.check_circle,
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (!context.mounted) return;
          if (userRole == 'admin' && email.endsWith('@kopiqu.com')) {
            Navigator.pushReplacementNamed(context, '/admin');
          } else if (userRole == 'pembeli') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          } else {
            FlushbarHelper.show(
              context,
              message: 'Email address atau role tidak sesuai.',
              backgroundColor: Colors.orange,
              icon: Icons.warning,
            );
            Future.delayed(const Duration(seconds: 2), () async {
              await supabase.auth.signOut();
              if (context.mounted)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
            });
          }
        });
      }
    } on AuthException {
      if (context.mounted)
        FlushbarHelper.show(
          context,
          message: 'Email atau password salah!',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
    } catch (e) {
      if (context.mounted)
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
      if (context.mounted) {
        await FlushbarHelper.show(
          context,
          message: 'Berhasil logout.',
          backgroundColor: Colors.green,
          icon: Icons.check_circle,
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted)
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
        });
      }
    } catch (e) {
      if (context.mounted)
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
      if (context.mounted)
        FlushbarHelper.show(
          context,
          message:
              'Link reset password telah dikirim ke email Anda. Silakan cek email.',
          backgroundColor: Colors.green,
          icon: Icons.check_circle,
        );
    } on AuthException catch (e) {
      if (context.mounted)
        FlushbarHelper.show(
          context,
          message: 'Gagal mengirim link reset: ${e.message}',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
    } catch (e) {
      if (context.mounted)
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
          if (context.mounted)
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
        });
        return;
      }
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      if (context.mounted) {
        await FlushbarHelper.show(
          context,
          message:
              'Password berhasil diperbarui! Silakan login dengan password baru Anda.',
          backgroundColor: Colors.green,
          icon: Icons.check_circle,
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted)
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
        });
      }
    } on AuthException catch (e) {
      if (context.mounted)
        FlushbarHelper.show(
          context,
          message: 'Gagal memperbarui password: ${e.message}',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
    } catch (e) {
      if (context.mounted)
        FlushbarHelper.show(
          context,
          message: 'Terjadi kesalahan saat memperbarui password: $e',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
    }
  }

  // Anda sudah memiliki updateEmail, ini bisa tetap ada jika diperlukan secara terpisah
  Future<void> updateEmail(String newEmail, BuildContext context) async {
    try {
      await supabase.auth.updateUser(UserAttributes(email: newEmail));
      // PERHATIAN: Mengubah email biasanya memerlukan konfirmasi email baru.
      // Supabase akan mengirim email konfirmasi. Beri tahu pengguna.
      if (context.mounted) {
        FlushbarHelper.show(
          context,
          message:
              'Link konfirmasi email baru telah dikirim ke $newEmail. Silakan cek email Anda.',
          backgroundColor: Colors.green,
          icon: Icons.check_circle,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      if (context.mounted) {
        FlushbarHelper.show(
          context,
          message: 'Gagal update email: $e',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    }
  }

  // 👇 2. METHOD BARU/MODIFIKASI UNTUK UPDATE USER METADATA (NAMA & FOTO PROFIL)
  Future<void> updateUserMetadata({
    String? displayName,
    String? photoUrl,
    // Anda bisa tambahkan BuildContext context jika ingin menampilkan Flushbar dari sini
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      print('Error: Pengguna tidak login saat mencoba update metadata.');
      throw Exception('Pengguna tidak login.');
    }

    final Map<String, dynamic> metadataUpdate = {};
    bool needsUpdate = false;

    if (displayName != null &&
        displayName.isNotEmpty &&
        displayName != user.userMetadata?['display_name']) {
      metadataUpdate['display_name'] = displayName;
      needsUpdate = true;
    }
    if (photoUrl != null &&
        photoUrl.isNotEmpty &&
        photoUrl != user.userMetadata?['photo_url']) {
      metadataUpdate['photo_url'] = photoUrl;
      needsUpdate = true;
    }

    // Selalu sertakan role yang sudah ada agar tidak terhapus jika field lain diupdate
    // Kecuali jika Anda memang ingin bisa mengubah role dari sini.
    final String? currentUserRole = user.userMetadata?['role'];
    if (currentUserRole != null) {
      metadataUpdate['role'] = currentUserRole;
    } else {
      // Jika role belum ada, mungkin set default role 'pembeli'
      // metadataUpdate['role'] = 'pembeli';
    }

    if (needsUpdate ||
        (metadataUpdate.containsKey('role') &&
            metadataUpdate['role'] != currentUserRole)) {
      // Hanya update jika ada displayName atau photoUrl baru, ATAU jika role perlu diset/dipertahankan
      try {
        await supabase.auth.updateUser(UserAttributes(data: metadataUpdate));
        print('User metadata berhasil diupdate: $metadataUpdate');
      } on AuthException catch (e) {
        print('Auth Error saat update user metadata: ${e.message}');
        throw Exception('Gagal update metadata profil: ${e.message}');
      } catch (e) {
        print('Unexpected error saat update user metadata: $e');
        throw Exception('Terjadi kesalahan tidak terduga saat update profil.');
      }
    } else {
      print(
        'Tidak ada perubahan pada display name atau photo URL, metadata tidak diupdate.',
      );
    }
  }

  // 👇 3. METHOD BARU UNTUK UPLOAD FOTO PROFIL
  Future<String?> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      final String fileExtension = imageFile.path.split('.').last.toLowerCase();
      final String fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      // Simpan di folder publik di dalam folder user, misal: public/user_id/profile_xxxxx.jpg
      final String filePath = '$userId/$fileName';

      print('Mengupload foto ke Supabase Storage: $filePath');

      // Pastikan bucket Anda bernama 'profile-pictures' atau sesuaikan namanya.
      // Dan pastikan policy RLS untuk bucket ini sudah benar.
      await supabase.storage
          .from('profile-pictures')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600', // Cache di browser selama 1 jam
              upsert:
                  false, // Gagal jika file sudah ada (untuk menghindari rewrite tidak sengaja)
              // Atau true jika ingin bisa menimpa dengan nama yang sama (perlu penanganan nama file yang lebih baik)
            ),
          );

      // Dapatkan URL publik dari gambar yang diupload
      final String publicUrl = supabase.storage
          .from('profile-pictures') // Sesuaikan nama bucket
          .getPublicUrl(filePath);

      print('Foto berhasil diupload. URL Publik: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      print('Supabase Storage Error - Gagal upload foto profil: ${e.message}');
      // Error umum: object not found (jika path salah atau bucket belum ada),
      // atau RLS policy melarang upload.
      throw Exception('Gagal upload foto: ${e.message}');
    } catch (e) {
      print('Error tidak terduga saat upload foto profil: $e');
      throw Exception('Gagal upload foto profil.');
    }
  }

  // Method updateDisplayName yang lama Anda.
  // Sebaiknya gunakan updateUserMetadata untuk konsistensi.
  // Jika Anda tetap ingin menggunakan ini, pastikan ia memanggil updateUserMetadata.
  Future<void> updateDisplayName(
    String newDisplayName,
    BuildContext context,
  ) async {
    try {
      // Memanggil method updateUserMetadata yang lebih generik
      await updateUserMetadata(displayName: newDisplayName);

      if (context.mounted) {
        FlushbarHelper.show(
          context,
          message: 'Nama berhasil diperbarui!',
          backgroundColor: Colors.green,
          icon: Icons.check_circle,
        );
      }
    } catch (e) {
      if (context.mounted) {
        FlushbarHelper.show(
          context,
          message:
              'Gagal memperbarui nama: ${e.toString()}', // Ambil message dari exception
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    }
  }
}
