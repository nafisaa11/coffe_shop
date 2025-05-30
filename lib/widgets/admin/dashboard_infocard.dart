import 'package:flutter/material.dart';

class DashboardInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor; // Tambahkan parameter ini
  final Color? textColor;       // Tambahkan parameter ini (opsional)

  const DashboardInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor, // Jadikan required atau beri default
    this.iconColor = Colors.white,  // Default iconColor
    this.textColor,                 // Bisa null, kita akan tangani defaultnya
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan warna teks default berdasarkan kecerahan backgroundColor
    // Jika tidak ada textColor spesifik yang diberikan.
    final Color defaultTextColor =
        ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
            ? Colors.white
            : Colors.black;
    final Color currentTextColor = textColor ?? defaultTextColor;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: backgroundColor, // Gunakan backgroundColor yang diteruskan
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Agar value bisa lebih ke bawah jika perlu
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start, // Agar ikon sejajar dengan baris pertama teks
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle( // Hapus const agar bisa dinamis
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: currentTextColor, // Gunakan textColor yang sudah ditentukan
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2, // Batasi jumlah baris judul jika terlalu panjang
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: iconColor, size: 28),
              ],
            ),
            const Spacer(), // Tambahkan Spacer untuk mendorong value ke bawah jika ruang vertikal cukup
            Text(
              value,
              style: TextStyle( // Hapus const
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: currentTextColor, // Gunakan textColor yang sudah ditentukan
              ),
            ),
          ],
        ),
      ),
    );
  }
}