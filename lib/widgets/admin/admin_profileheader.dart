// lib/widgets/admin/admin_profile_header.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/admin/admin_profilecolor.dart'; // Menggunakan warna terpusat

class AdminProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? avatarUrl; // URL avatar bisa null

  const AdminProfileHeader({
    super.key,
    required this.displayName,
    required this.email,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Dekorasi untuk gradient background
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [AdminProfileColors.primaryColor, AdminProfileColors.secondaryColor],
        ),
      ),
      child: SafeArea( // Memastikan konten tidak terpotong oleh notch atau status bar
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Kontainer untuk avatar dengan border dan shadow
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: AdminProfileColors.accentColor,
                  backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                      ? NetworkImage(avatarUrl!) // Tampilkan gambar dari network jika ada
                      : null, // Jika tidak, tampilkan child (Icon)
                  child: (avatarUrl == null || avatarUrl!.isEmpty)
                      ? const Icon( // Icon default jika tidak ada avatar
                          Icons.admin_panel_settings_rounded,
                          size: 60,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              // Teks untuk nama display
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Kontainer untuk email dengan background transparan
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20), // Spasi tambahan untuk efek tumpukan
            ],
          ),
        ),
      ),
    );
  }
}