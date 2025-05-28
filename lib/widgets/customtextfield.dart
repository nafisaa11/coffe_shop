import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final bool readOnly; // Tambahkan ini
  final TextStyle? customLabelStyle; // Tambahkan ini
  final TextStyle?
  inputTextStyle; // Tambahkan ini untuk style teks di dalam field

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    required this.controller,
    this.readOnly = false, // Default ke false
    this.customLabelStyle, // Default ke null
    this.inputTextStyle, // Default ke null
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan style default untuk readOnly jika tidak ada style khusus yang diberikan
    final defaultReadOnlyLabelStyle = TextStyle(color: Colors.grey[600]);
    final defaultReadOnlyInputStyle = TextStyle(color: Colors.grey[700]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          // Gunakan customLabelStyle jika ada,
          // jika tidak dan readOnly, gunakan defaultReadOnlyLabelStyle,
          // jika tidak (readOnly false dan customLabelStyle null), gunakan style default Text
          style:
              customLabelStyle ?? (readOnly ? defaultReadOnlyLabelStyle : null),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          readOnly: readOnly, // Terapkan readOnly di sini
          // Gunakan inputTextStyle jika ada,
          // jika tidak dan readOnly, gunakan defaultReadOnlyInputStyle,
          // jika tidak (readOnly false dan inputTextStyle null), gunakan style default TextField
          style:
              inputTextStyle ?? (readOnly ? defaultReadOnlyInputStyle : null),
          decoration: InputDecoration(
            hintText: hintText,
            // Beri warna berbeda pada border jika readOnly untuk indikasi visual tambahan (opsional)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color:
                    readOnly
                        ? Colors.grey[400]!
                        : Colors.grey, // Warna border berbeda jika readOnly
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: readOnly ? Colors.grey[400]! : Colors.brown,
              ), // Warna focus border
              borderRadius: BorderRadius.circular(8),
            ),
            // Mengisi field dengan warna abu-abu jika readOnly (opsional)
            filled: readOnly,
            fillColor: readOnly ? Colors.grey[200] : null,
          ),
        ),
      ],
    );
  }
}

// CustomButton tetap sama, tidak perlu diubah untuk ini
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? iconData; // Jadikan icon opsional

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.iconData, // Tambahkan parameter iconData
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child:
          iconData !=
                  null // Cek apakah iconData ada
              ? ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: onPressed,
                icon: Icon(
                  iconData, // Gunakan iconData jika ada
                  color: Colors.white,
                ),
                label: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
              : ElevatedButton(
                // Jika tidak ada iconData, gunakan ElevatedButton biasa
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: onPressed,
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
    );
  }
}
