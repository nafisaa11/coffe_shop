import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/customtextfield.dart';


class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/kopiqu.png',
                  width: 150,
                ),
                const SizedBox(height: 24),
                Image.asset(
                  'assets/iconlogin.png',
                  height: 150,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Email',
                  hintText: 'Masukkan Email',
                  controller: emailController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Password',
                  hintText: 'Masukkan Password',
                  obscureText: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Masuk',a
                  onPressed: () {
                    // action login di sini
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum memiliki akun? '),
                    GestureDetector(
                      onTap: () {
                        // navigate ke halaman registrasi
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
      ),
    );
  }
}
