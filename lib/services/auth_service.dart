import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/screens/mainscreen.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:kopiqu/screens/loginpage.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<void> register(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final User? user = res.user;

      if (user != null) {
        Flushbar(
          message: 'Registrasi berhasil! Silakan login.',
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(Icons.check_circle, color: Colors.white),
          animationDuration: const Duration(milliseconds: 500),
        ).show(context);

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        });
      }
    } on AuthException catch (e) {
      Flushbar(
        message: e.message,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: const Icon(Icons.error, color: Colors.white),
        animationDuration: const Duration(milliseconds: 500),
      ).show(context);
    } catch (e) {
      Flushbar(
        message: e.toString(),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: const Icon(Icons.error, color: Colors.white),
        animationDuration: const Duration(milliseconds: 500),
      ).show(context);
    }
  }

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final User? user = res.user;

      if (user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      Flushbar(
        message: e.message,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: const Icon(Icons.error, color: Colors.white),
        animationDuration: const Duration(milliseconds: 500),
      ).show(context);
    } catch (e) {
      Flushbar(
        message: e.toString(),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: const Icon(Icons.error, color: Colors.white),
        animationDuration: const Duration(milliseconds: 500),
      ).show(context);
    }
  }
}
