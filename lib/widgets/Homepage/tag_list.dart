// widgets/Homepage/tag_list.dart
import 'package:flutter/material.dart';

class TagList extends StatelessWidget {
  final String activeTag; // Tag yang sedang aktif
  final Function(String) onTagSelected; // Callback saat tag dipilih

  const TagList({
    super.key,
    required this.activeTag,
    required this.onTagSelected,
  });

  // Definisikan tag dan warnanya di sini agar mudah dikelola
  static const String tagRekomendasi = 'Rekomendasi';
  static const String tagPalingMurah = 'Paling Murah';

  // Warna untuk tag aktif dan tidak aktif
  static const Color activeBackgroundColor = Color(
    0xFF4D2F15,
  ); // Coklat tua (seperti di contoh Anda)
  static const Color activeTextColor = Colors.white;
  static const Color inactiveBackgroundColor = Color(
    0xFFE3B28C,
  ); // Krem (seperti di contoh Anda)
  static const Color inactiveTextColor = Color.fromARGB(255, 156, 109, 67);
  static const Color borderColor = Color(0xFF4D2F15);

  Widget _buildTag(BuildContext context, String text) {
    bool isActive = activeTag == text;
    return GestureDetector(
      onTap: () => onTagSelected(text), // Panggil callback saat tag ditekan
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ), // Padding lebih besar
        decoration: BoxDecoration(
          color: isActive ? activeBackgroundColor : inactiveBackgroundColor,
          borderRadius: BorderRadius.circular(
            12.0,
          ), // Border radius lebih besar untuk tampilan "pill"
          border: Border.all(color: borderColor, width: 1),
          boxShadow:
              isActive
                  ? [
                    // Beri sedikit shadow jika aktif
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? activeTextColor : const Color.fromARGB(255, 155, 112, 75),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal, // Lebih tebal
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        // Menggunakan Wrap jika tag bisa lebih dari satu baris
        spacing: 10.0, // Jarak horizontal antar tag
        runSpacing: 8.0, // Jarak vertikal antar baris tag
        children: [
          _buildTag(context, tagRekomendasi),
          _buildTag(context, tagPalingMurah),
          // Anda bisa menambahkan tag lain di sini jika perlu
        ],
      ),
    );
  }
}
