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

void main() {
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KopiQu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 255, 255)),
      ),
      home: StrukPage(transaksi: dummyTransaksi), // Ganti dengan halaman awal yang diinginkan
      //StrukPage(transaksi: dummyTransaksi), // Ganti dengan id yang sesuai
    );
  } 
} 
