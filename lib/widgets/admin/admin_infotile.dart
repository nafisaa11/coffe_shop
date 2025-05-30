import 'package:flutter/material.dart';

class ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;

  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor = const Color(0xFF804E23), // Coklat Tua
    this.titleColor = Colors.black87,
    this.subtitleColor = const Color(0xFFA28C79), // Coklat Muda/Abu-abu
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: subtitleColor, fontSize: 14),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 0,
      ), // Sesuaikan padding
      // trailing: onTap != null ? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]) : null,
    );
  }
}
