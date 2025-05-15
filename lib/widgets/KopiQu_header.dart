import 'package:flutter/material.dart';

class KopiQuHeader extends StatelessWidget {
  const KopiQuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD07C3D),
      padding: const EdgeInsets.symmetric(vertical: 15), // Tambah tinggi header
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // agar teks sejajar tengah
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 20),
            child: Image.asset(
              'assets/kopiqu.png',
              width: 120,
            ),
          ),
          // Greeting Text
          const Padding(
            padding: EdgeInsets.only(right: 16, top: 30),
            child: Text(
              'Halo Guest ....',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
