import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/KeranjangController.dart';
import 'package:kopiqu/screens/keranjangScreen.dart';

class SearchWidget extends StatelessWidget {
  // final TextEditingController controller;
  final Function(String)? onChanged;

  const SearchWidget({
    Key? key,
    // required this.controller,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search Bar
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    // controller: controller,
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      hintText: 'Cari minuman seleramu ...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Icon(Icons.search, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Cart Icon
        IconButton(
          onPressed: () {
            KeranjangScreen();
          },
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.grey),
        ),
      ],
    );
  }
}
