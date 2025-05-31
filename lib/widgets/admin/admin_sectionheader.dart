// lib/widgets/admin/section_header.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/admin/admin_profilecolor.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AdminProfileColors.textPrimary,
      ),
    );
  }
}