import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/KeranjangController.dart';
import 'package:kopiqu/dummy/dummy_transaksi.dart';
import 'package:kopiqu/screens/Homepage.dart';
import 'package:kopiqu/screens/detailProdukScreen.dart';
import 'package:kopiqu/screens/keranjangScreen.dart';
import 'package:kopiqu/screens/struk.dart';
import 'package:provider/provider.dart';
import 'package:kopiqu/screens/loginpage.dart';
import 'package:kopiqu/screens/registerpage.dart';
import 'package:kopiqu/screens/profile_page.dart';
import 'package:kopiqu/screens/menupage.dart';
import 'package:kopiqu/screens/mainscreen.dart';
import 'package:kopiqu/screens/riwayat_pembelian_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      home:  LoginPage(),
      routes: {
        '/menu': (context) => const MenuPage(),
        '/home': (context) => const Homepage(),
        '/profile': (context) => const ProfilePage(),
        '/keranjang': (context) => KeranjangScreen(),
      },
    );
  }
}
