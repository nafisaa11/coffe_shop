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

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => KeranjangController())],
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
      home: const MainScreen(),
      routes: {
        '/menu': (context) => const MenuPage(),
        '/home': (context) => const Homepage(),
        '/profile': (context) => const ProfilePage(),
        '/keranjang': (context) => KeranjangScreen()
      },

    );
  }
}
