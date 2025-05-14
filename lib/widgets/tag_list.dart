import 'package:flutter/material.dart';

class TagList extends StatelessWidget {
  const TagList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8.0, // Jarak horizontal antar tag
        runSpacing: 8.0, // Jarak vertikal antar baris tag
        children: [
          _buildTag('Rekomendasi', backgroundColor: const Color(0xFF4D2F15), textColor: Colors.white),
          _buildTag('Terbaru', backgroundColor: const Color(0xFFE3B28C), textColor: Colors.black),
          _buildTag('Paling Murah', backgroundColor: const Color(0xFFE3B28C), textColor: Colors.black),
        ],
      ),
    );
  }

  Widget _buildTag(String text, {required Color backgroundColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFF4D2F15), width: 1.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 14.0,
        ),
      ),
    );
  }
}
