import 'package:flutter/material.dart';
import 'package:kopiqu/screens/Homepage.dart';
import 'package:kopiqu/screens/loginpage.dart';
import 'package:kopiqu/screens/registerpage.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 255, 255)),
      ),
      home: Homepage(),
    );
  } 
} 
