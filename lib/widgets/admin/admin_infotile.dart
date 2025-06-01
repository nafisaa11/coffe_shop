// lib/widgets/admin/admin_infotile.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/admin/admin_profilecolor.dart';

// Widget untuk menampilkan baris statistik cepat (Login Terakhir & Login Hari Ini)
class AdminQuickStatsSection extends StatelessWidget {
  final String? lastLogin;
  final int loginsToday;

  const AdminQuickStatsSection({
    super.key,
    this.lastLogin,
    required this.loginsToday,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          // Kartu statistik pertama
          child: _StatCard(
            // Menggunakan widget helper _StatCard
            icon: Icons.history_toggle_off_rounded,
            title: 'Login Terakhir',
            value: lastLogin ?? '-', // Tampilkan '-' jika lastLogin null
            color: AdminProfileColors.primaryColor,
          ),
        ),
        const SizedBox(width: 16), // Spasi antar kartu
        Expanded(
          // Kartu statistik kedua
          child: _StatCard(
            icon: Icons.today_rounded,
            title: 'Login Hari Ini',
            value: '$loginsToday kali',
            color: AdminProfileColors.secondaryColor,
          ),
        ),
      ],
    );
  }
}

// Widget private untuk menampilkan satu kartu statistik
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color; // Warna utama untuk icon dan aksennya

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(
        minHeight: 140,
        maxHeight: 175, // Tinggi minimum untuk kartu
      ),
      decoration: BoxDecoration(
        color: AdminProfileColors.cardColor, // Warna latar kartu
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Efek bayangan halus
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon dengan background berwarna
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1), // Warna aksen dengan opacity
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          // Judul statistik
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AdminProfileColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          // Nilai statistik
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AdminProfileColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
