import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/KopiController.dart';
import 'package:kopiqu/widgets/Homepage/kopi_card.dart';
import '../models/kopi.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final kopiService = KopiController();
  late Future<List<Kopi>> futureKopi;

  @override
  void initState() {
    super.initState();
    futureKopi = kopiService.getAllKopi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu Kopi")),
      body: FutureBuilder<List<Kopi>>(
        future: futureKopi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final kopiList = snapshot.data ?? [];

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: kopiList.length,
            itemBuilder: (context, index) {
              return CoffeeCard(kopi: kopiList[index]);
            },
          );
        },
      ),
    );
  }
}
