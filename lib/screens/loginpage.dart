import 'package:flutter/material.dart';
import 'package:kopiqu/screens/registerpage.dart';
import 'package:kopiqu/services/auth_service.dart';
import 'package:kopiqu/widgets/customtextfield.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
              const SizedBox(height: 35), // jarak dari atas ke logo
              Image.asset('assets/kopiqu.png', width: 150),
              const SizedBox(height: 32), // jarak antar logo ke icon login
              Center(child: Image.asset('assets/iconlogin.png', height: 170)),
              const SizedBox(height: 32), // jarak ke textfield
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
              const SizedBox(height: 160), // jarak textfield ke tombol
              CustomButton(
                text: 'Masuk',
                onPressed: () async {
                  await AuthService().login(
                    emailController.text,
                    passwordController.text,
                    context,
                  );
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
                      ); // navigate ke halaman registrasi
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
