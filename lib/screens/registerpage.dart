import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/customtextfield.dart'; // PASTIKAN PATH INI BENAR
import 'package:kopiqu/screens/loginpage.dart';
import 'package:kopiqu/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

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
      // backgroundColor: Color(0xFF8D6E63), // Dihapus untuk diganti dengan gradasi
      body: Container( // Container untuk gradasi latar belakang
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8D6E63), // Coklat di atas
              Colors.white,      // Putih di bawah
            ],
            stops: [0.0, 0.7], // Titik henti gradasi, sesuaikan jika perlu
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
                mainAxisAlignment: MainAxisAlignment.start, // Konten mulai dari atas
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Kopiqu di atas, putih agar kontras dengan coklat
                  Image.asset(
                    'assets/kopiqu.png',
                    width: 120, // Disesuaikan ukurannya
                    height: 50, // Disesuaikan ukurannya
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  // Ikon login (atau register), tanpa warna tambahan
                  Image.asset('assets/iconlogin.png', height: 170), // Anda mungkin ingin menggunakan ikon register jika ada
                  const SizedBox(height: 25),
                  // Container putih untuk form register
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
                          'Daftar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Teks Register di dalam box tetap hitam
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
                          obscureText: true,
                          controller: passwordController,
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          label: 'Konfirmasi Password',
                          hintText: 'Masukkan Konfirmasi Password',
                          obscureText: true,
                          controller: confirmPasswordController,
                        ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8D6E63))))
                            : CustomButton(
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
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Masuk',
                                style: TextStyle(
                                  color: Color(0xFF795548), // Warna coklat untuk link
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