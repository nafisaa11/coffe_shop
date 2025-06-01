import 'package:flutter/material.dart';
import 'package:kopiqu/screens/registerpage.dart';
import 'package:kopiqu/services/auth_service.dart';
import 'package:kopiqu/widgets/customtextfield.dart';
import 'package:lottie/lottie.dart';
import 'package:kopiqu/widgets/forgotpassworddialog.dart';
// PASTIKAN PATH INI BENAR

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final resetEmailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    resetEmailController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog() {
    showForgotPasswordDialog(
      context: context,
      resetEmailController: resetEmailController,
      onLoadingStart: () {
        if (mounted) setState(() => _isLoading = true);
      },
      onLoadingEnd: () {
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
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
                  Image.asset('assets/iconlogin.png', height: 170),
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
                          'Masuk',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 25),
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
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap:
                                _isLoading ? null : _showForgotPasswordDialog,
                            child: const Text(
                              'Lupa Password?',
                              style: TextStyle(
                                color: Color(0xFF795548),
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? Center(
                              child: SizedBox(
                                width: 120, // Sesuaikan ukuran animasi Lottie
                                height: 120,
                                // 1. UBAH KE Lottie.asset
                                child: Lottie.asset(
                                  'assets/lottie/animation-loading.json', // Path ke file JSON Anda
                                  onLoaded: (composition) {
                                    print(
                                      "Animasi Lottie (aset) berhasil dimuat.",
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                      "Error memuat Lottie dari aset: $error",
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
                              text: 'Masuk',
                              iconData: Icons.login,
                              onPressed: () async {
                                setState(() => _isLoading = true);
                                await AuthService().login(
                                  emailController.text,
                                  passwordController.text,
                                  context,
                                );
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                }
                              },
                            ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Belum memiliki akun? ',
                              style: TextStyle(color: Colors.black87),
                            ),
                            GestureDetector(
                              onTap:
                                  _isLoading
                                      ? null
                                      : () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => RegisterPage(),
                                          ),
                                        );
                                      },
                              child: const Text(
                                'Registrasi',
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
