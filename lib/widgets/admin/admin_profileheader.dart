import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String displayName;
  final String email;
  final String? avatarUrl; // Opsional, jika ada URL gambar profil
  final IconData fallbackIcon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const ProfileHeaderCard({
    super.key,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.fallbackIcon = Icons.admin_panel_settings_sharp,
    this.backgroundColor = const Color(0xFFD3864A), // Warna utama dari skema Anda
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? NetworkImage(avatarUrl!)
                : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? Icon(fallbackIcon, size: 50, color: iconColor)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 15,
              color: textColor.withOpacity(0.85),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}