import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  String displayName = 'Pengguna';
  String email = 'example@email.com';

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      displayName = user?.userMetadata?['display_name'] ?? 'Pengguna';
      email = user?.email ?? 'example@email.com';
    });
  }

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
          // Display name dari metadata + icon edit
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayName,
                style: const TextStyle(
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
          const SizedBox(height: 4),
          // Email pengguna
          Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
