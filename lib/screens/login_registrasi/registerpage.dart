import 'package:flutter/material.dart';
import 'package:kopiqu/screens/login_registrasi/loginpage.dart';
import 'package:kopiqu/widgets/customtextfield.dart'; // PASTIKAN PATH INI BENAR
import 'package:kopiqu/services/auth_service.dart';
import 'package:lottie/lottie.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
  }); // Direkomendasikan menggunakan const constructor

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Gunakan const jika tidak ada variabel
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8D6E63), Colors.white],
            stops: [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/kopiqu.png',
                    width: 120,
                    height: 50,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/iconlogin.png',
                    height: 170,
                  ), // Pertimbangkan menggunakan ikon register
                  const SizedBox(height: 25),
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
                          // Gunakan const
                          'Daftar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          label: 'Email',
                          hintText: 'Masukkan Email',
                          controller: emailController,
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          label: 'Password',
                          hintText: 'Masukkan Password',
                          obscureTextInitially: true,
                          isPasswordTextField: true,
                          controller: passwordController,
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          label: 'Konfirmasi Password',
                          hintText: 'Masukkan Konfirmasi Password',
                          obscureTextInitially: true,
                          isPasswordTextField: true,
                          controller: confirmPasswordController,
                        ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? Center(
                              child: SizedBox(
                                width: 120, // Sesuaikan ukuran animasi Lottie
                                height: 120,
                                // 2. Tambahkan Lottie Widget di sini
                                child: Lottie.asset(
                                  'assets/lottie/animation-loading.json', // Pastikan path ini benar
                                  onLoaded: (composition) {
                                    print(
                                      "Animasi Lottie (aset) berhasil dimuat untuk RegisterPage.",
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                      "Error memuat Lottie dari aset untuk RegisterPage: $error",
                                    );
                                    return const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF8D6E63),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                            : CustomButton(
                              // Pastikan CustomButton di-import atau didefinisikan
                              text: 'Daftar',
                              iconData: Icons.person_add_alt_1,
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                await AuthService().register(
                                  emailController.text,
                                  passwordController.text,
                                  confirmPasswordController.text,
                                  context,
                                );
                                if (mounted) {
                                  // Selalu cek 'mounted' setelah async gap
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              },
                            ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sudah memiliki akun? ',
                              style: TextStyle(color: Colors.black87),
                            ),
                            GestureDetector(
                              onTap:
                                  _isLoading
                                      ? null
                                      : () {
                                        // Nonaktifkan tap saat loading
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const LoginPage(), // Gunakan const
                                          ),
                                        );
                                      },
                              child: const Text(
                                // Gunakan const
                                'Masuk',
                                style: TextStyle(
                                  color: Color(0xFF795548),
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
