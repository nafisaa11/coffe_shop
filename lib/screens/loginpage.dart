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

  bool _isLoading = false; // 👈 state loading

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
                  onTap: () {
                    print("Klik Lupa Password");
                  },
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
              const SizedBox(height: 160),

              // Tombol login atau animasi loading
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                    text: 'Masuk',
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });

                      await AuthService().login(
                        emailController.text,
                        passwordController.text,
                        context,
                      );

                      setState(() {
                        _isLoading = false;
                      });
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
