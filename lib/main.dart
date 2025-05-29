import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/Keranjang_Controller.dart';
import 'package:kopiqu/screens/Homepage.dart';
import 'package:kopiqu/screens/keranjangScreen.dart';
import 'package:kopiqu/screens/loginpage.dart';
import 'package:kopiqu/screens/mainscreen.dart';
import 'package:kopiqu/screens/transaksiScreen.dart';
import 'package:kopiqu/services/getKopi_servce.dart';
import 'package:provider/provider.dart';
import 'package:kopiqu/screens/profile_page.dart';
import 'package:kopiqu/screens/menupage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/screens/admin/admindashboard.dart';

Future<void> main() async {
  // Wajib: inisialisasi Flutter sebelum async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://xuivlesfrjbjtaaavtma.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh1aXZsZXNmcmpianRhYWF2dG1hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyODc3OTgsImV4cCI6MjA2Mjg2Mzc5OH0.g33UOprpbbVXqpXtP3tY2nedOeCZklO003S4aZrUQsE',
  );

  // Jalankan aplikasi dengan MultiProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KeranjangController()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KopiQu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
      home:  AuthGate(),
      routes: {
        '/menu': (context) => MenuPage(),
        '/home': (context) => const Homepage(),
        '/profile': (context) => const ProfilePage(),
        '/keranjang': (context) => KeranjangScreen(),
        '/periksa': (context) => const PeriksaPesananScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan StreamBuilder untuk mendengarkan perubahan status autentikasi
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Saat stream masih menunggu data awal (misalnya, memulihkan sesi)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Jika ada data sesi di stream (artinya pengguna sudah login)
        if (snapshot.hasData && snapshot.data?.session != null) {
          return const MainScreen(); // Arahkan ke Homepage
        } else {
          // Jika tidak ada sesi, atau terjadi error (snapshot.hasError)
          // atau stream selesai tanpa sesi (jarang terjadi untuk onAuthStateChange)
          return const LoginPage(); // Arahkan ke LoginPage
        }
      },
    );
  }
}
