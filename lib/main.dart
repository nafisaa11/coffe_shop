import 'package:flutter/material.dart';
import 'package:kopiqu/screens/Homepage.dart';
import 'package:kopiqu/screens/detailProdukScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KopiQu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFD3864A)),
      ),
      home: Homepage(),
    );
  } 
}
