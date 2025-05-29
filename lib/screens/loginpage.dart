import 'package:flutter/material.dart';
import 'package:kopiqu/screens/registerpage.dart';
import 'package:kopiqu/services/auth_service.dart';
// Impor widget kustom Anda di sini, contoh:
import 'package:kopiqu/widgets/customtextfield.dart'; // PASTIKAN PATH INI BENAR

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
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Lupa Password'),
          content: CustomTextField(
            label: 'Email',
            hintText: 'Masukkan email terdaftar',
            controller: resetEmailController,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8D6E63),
              ), // Warna tombol coklat
              onPressed: () async {
                if (resetEmailController.text.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  setState(() => _isLoading = true);
                  await AuthService().sendPasswordResetEmail(
                    resetEmailController.text,
                    context,
                  );
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                  resetEmailController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFF8D6E63), // Dihapus untuk diganti dengan gradasi
      body: Container(
        // Container untuk gradasi latar belakang
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8D6E63), // Coklat di atas
              Colors.white, // Putih di bawah
            ],
            stops: [
              0.0,
              0.7,
            ], // Titik henti gradasi, 0.7 berarti putih mulai dominan dari 70% ke bawah
            // Anda bisa sesuaikan nilai ini (misal 0.5, 0.8, atau hapus 'stops' untuk default)
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
                mainAxisAlignment:
                    MainAxisAlignment.start, // Konten mulai dari atas
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Kopiqu di atas, tetap putih agar kontras dengan coklat
                  Image.asset(
                    'assets/kopiqu.png',
                    width: 120, // Sedikit disesuaikan ukurannya
                    height: 50, // Sedikit disesuaikan ukurannya
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  // Ikon login, tanpa warna tambahan agar sesuai aslinya
                  Image.asset('assets/iconlogin.png', height: 170),
                  const SizedBox(height: 25),
                  // Container putih untuk form login
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Masuk',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color:
                                Colors
                                    .black, // Teks Login di dalam box tetap hitam
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
                          obscureText: true,
                          controller: passwordController,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _showForgotPasswordDialog,
                            child: Text(
                              'Lupa Password?',
                              style: TextStyle(
                                color: Color.fromARGB(255, 30, 37, 255), // Warna coklat untuk link
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF8D6E63),
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
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Registrasi',
                                style: TextStyle(
                                  color: Color(
                                    0xFF795548,
                                  ), // Warna coklat untuk link
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
