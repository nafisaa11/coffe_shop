import 'package:flutter/material.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/kopi_card.dart'; // Import widget card Anda

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // Contoh data kopi (sesuaikan dengan model Anda)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Kopi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Jumlah kolom
            crossAxisSpacing: 16, // Spasi horizontal antar item
            mainAxisSpacing: 16, // Spasi vertikal antar item
            childAspectRatio: 0.75, // Rasio lebar/tinggi card
          ),
          itemCount: kopiList.length,
          itemBuilder: (context, index) {
            return CoffeeCard(kopi: kopiList[index]);
          },
        ),
      ),
    );
  }
}