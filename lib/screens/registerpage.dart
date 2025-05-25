import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/customtextfield.dart';
import 'package:kopiqu/screens/loginpage.dart';
import 'package:kopiqu/services/auth_service.dart'; // import AuthService


class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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
              const SizedBox(height: 15),
              CustomTextField(
                label: 'Konfirmasi Password',
                hintText: 'Masukkan Konfirmasi Password',
                obscureText: true,
                controller: confirmPasswordController,
              ),
              const SizedBox(height: 60),
              CustomButton(
                text: 'Daftar',
                onPressed: () async {
                  await AuthService().register(
                    emailController.text,
                    passwordController.text,
                    confirmPasswordController.text,
                    context,
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah memiliki akun? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text(
                      'Masuk',
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
