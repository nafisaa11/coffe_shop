import 'package:flutter/material.dart';
import 'package:kopiqu/screens/login_registrasi/loginpage.dart';
import 'package:kopiqu/widgets/customtextfield.dart'; // Pastikan path ini benar
import 'package:kopiqu/services/auth_service.dart';
import 'package:lottie/lottie.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  late TextEditingController emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    emailController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hapus backgroundColor di sini untuk menggunakan Container dengan gradasi
      body: Container( // 2. Bungkus dengan Container untuk gradasi
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8D6E63), // Warna coklat di atas
              Colors.white,      // Warna putih di bawah
            ],
            stops: [0.0, 0.7], // Sesuaikan titik henti gradasi jika perlu
          ),
        ),
        child: SafeArea(
          child: Center( // 3. Tambahkan Center agar konten di tengah
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0, // Sesuaikan padding vertikal jika perlu
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Konten mulai dari atas
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Kopiqu di atas, putih agar kontras
                  Image.asset(
                    'assets/kopiqu.png',
                    width: 120, // Sesuaikan ukuran agar konsisten
                    height: 50,  // Sesuaikan ukuran agar konsisten
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20), // Jarak konsisten
                  // Ikon (opsional, bisa disesuaikan atau dihilangkan jika tidak cocok)
                  Image.asset('assets/iconlogin.png', height: 170), // Pertimbangkan ikon yang lebih relevan
                  const SizedBox(height: 25), // Jarak konsisten

                  // Container putih untuk form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Atur Password Baru',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25, // Ukuran font konsisten
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          label: 'Email',
                          hintText: 'Email Anda',
                          controller: emailController,
                          readOnly: true,
                          // Style untuk readOnly field bisa disesuaikan di CustomTextField
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          label: 'Password Baru',
                          hintText: 'Masukkan Password Baru',
                          obscureTextInitially: true,
                          isPasswordTextField: true,
                          controller: newPasswordController,
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          label: 'Konfirmasi Password Baru',
                          hintText: 'Masukkan Konfirmasi Password Baru',
                          obscureTextInitially: true,
                          isPasswordTextField: true,
                          controller: confirmNewPasswordController,
                        ),
                        const SizedBox(height: 30), // Jarak sebelum tombol
                        _isLoading
                            ? Center(
                                child: SizedBox(
                                  width: 120, // Sesuaikan ukuran Lottie
                                  height: 120,
                                  // 4. Tambahkan Lottie Widget di sini
                                  child: Lottie.asset(
                                    'assets/lottie/animation-loading.json', // Pastikan path ini benar
                                    onLoaded: (composition) {
                                      print(
                                        "Animasi Lottie (aset) berhasil dimuat untuk ResetPasswordPage.",
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      print(
                                        "Error memuat Lottie dari aset untuk ResetPasswordPage: $error",
                                      );
                                      return const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF8D6E63), // Warna konsisten
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                            : CustomButton(
                                text: 'Ubah Password',
                                iconData: Icons.lock_reset, // Ikon opsional
                                onPressed: () async {
                                  setState(() => _isLoading = true);
                                  await AuthService().updateUserPassword(
                                    context,
                                    newPasswordController.text,
                                    confirmNewPasswordController.text,
                                  );
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                },
                              ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sudah ingat password? ',
                              style: TextStyle(color: Colors.black87), // Warna teks konsisten
                            ),
                            GestureDetector(
                              onTap: _isLoading ? null : () { // 5. Nonaktifkan tap saat loading
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()), // Gunakan const
                                );
                              },
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                  color: Color(0xFF795548), // Warna link konsisten
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}