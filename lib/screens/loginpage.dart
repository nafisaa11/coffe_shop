import 'package:flutter/material.dart';
import 'package:kopiqu/screens/registerpage.dart';
import 'package:kopiqu/services/auth_service.dart';
import 'package:kopiqu/widgets/customtextfield.dart';

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
      context:
          context, // Konteks ini adalah milik LoginPage, aman untuk showDialog
      builder: (dialogContext) {
        // Gunakan dialogContext untuk aksi di dalam dialog
        return AlertDialog(
          title: const Text('Lupa Password'),
          content: CustomTextField(
            label: 'Email',
            hintText: 'Masukkan email terdaftar',
            controller: resetEmailController,
          ),
          actions: [
            TextButton(
              onPressed:
                  () =>
                      Navigator.of(
                        dialogContext,
                      ).pop(), // Gunakan dialogContext
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (resetEmailController.text.isNotEmpty) {
                  Navigator.of(
                    dialogContext,
                  ).pop(); // Tutup dialog menggunakan dialogContext

                  // Gunakan context dari _LoginPageState (this.context) untuk AuthService
                  // karena sendPasswordResetEmail mungkin menampilkan Flushbar di LoginPage
                  setState(() => _isLoading = true);
                  await AuthService().sendPasswordResetEmail(
                    resetEmailController.text,
                    context, // this.context (milik _LoginPageState)
                  );

                  // Periksa apakah widget masih mounted sebelum setState
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                  resetEmailController.clear();
                }
              },
              child: const Text('Kirim Link Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),
              Image.asset('assets/kopiqu.png', width: 150),
              const SizedBox(height: 32),
              Center(child: Image.asset('assets/iconlogin.png', height: 170)),
              const SizedBox(height: 32),
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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _showForgotPasswordDialog,
                  child: const Text(
                    'Lupa Password?',
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 136), // Sesuaikan dengan layout Anda
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                    // Pastikan CustomButton sudah didefinisikan atau ganti dengan ElevatedButton
                    text: 'Masuk',
                    iconData:
                        Icons.login, // Jika CustomButton Anda mendukung ikon
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      await AuthService().login(
                        emailController.text,
                        passwordController.text,
                        context,
                      );
                      // Periksa apakah widget masih mounted sebelum setState
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    },
                  ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum memiliki akun? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: const Text(
                      'Registrasi',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
