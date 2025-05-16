import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFD07C3D),
      padding: const EdgeInsets.only(top: 35, bottom: 30),
      child: Column(
        children: [
          // Logo kiri atas
          Row(
            children: [
              const SizedBox(width: 16),
              Image.asset('assets/kopiqu.png', width: 120),
            ],
          ),
          const SizedBox(height: 20),
          // Foto profil
          Container(
            width: 100,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              image: const DecorationImage(
                image: AssetImage('assets/foto.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Teks Guest + Edit
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Guest',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                PhosphorIcons.pencilSimple(PhosphorIconsStyle.regular),
                color: Colors.black,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
