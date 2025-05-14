import 'package:flutter/material.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/kopi_card.dart';
import 'package:kopiqu/widgets/tag_list.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Kopi'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const TagList(), // Widget tag
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: kopiList.length,
                itemBuilder: (context, index) {
                  return CoffeeCard(kopi: kopiList[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
