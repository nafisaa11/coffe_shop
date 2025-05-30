import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/customtextfield.dart'; // Pastikan path ini benar
import 'package:kopiqu/screens/loginpage.dart';
import 'package:kopiqu/services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  // Ganti nama kelas jika perlu
  final String email;

  const ResetPasswordPage({
    super.key,
    required this.email,
  }); // Ganti nama konstruktor jika perlu

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState(); // Ganti nama state jika perlu
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  // Ganti nama state jika perlu
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
              const Center(
                child: Text(
                  'Atur Password Baru',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Email',
                hintText:
                    'Email Anda', // Hint text mungkin tidak terlihat jika field terisi
                controller: emailController,
                readOnly: true, // Atur readOnly
                // Atur style khusus jika diperlukan, jika tidak, default abu-abu akan diterapkan
                // customLabelStyle: TextStyle(color: Colors.grey[700]),
                // inputTextStyle: TextStyle(color: Colors.grey[800], fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                label: 'Password Baru',
                hintText: 'Masukkan Password Baru',
                obscureTextInitially: true, // Password disembunyikan di awal
                isPasswordTextField: true,
                controller: newPasswordController,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                label: 'Konfirmasi Password Baru',
                hintText: 'Masukkan Konfirmasi Password Baru',
                obscureTextInitially: true, // Password disembunyikan di awal
                isPasswordTextField: true,
                controller: confirmNewPasswordController,
              ),
              const SizedBox(height: 46),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                    // Menggunakan CustomButton yang sudah dimodifikasi
                    text: 'Ubah Password',
                    // iconData: Icons.lock_reset, // Opsional: tambahkan ikon jika mau
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
                  const Text('Sudah ingat password? '),
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
