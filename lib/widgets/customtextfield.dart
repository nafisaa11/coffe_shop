import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart'; // Pastikan ini sudah ada di pubspec.yaml

class CustomTextField extends StatefulWidget { // 1. Ubah menjadi StatefulWidget
  final String label;
  final String hintText;
  final bool obscureTextInitially; // 2. Ganti nama dari obscureText
  final TextEditingController controller;
  final bool readOnly;
  final TextStyle? customLabelStyle;
  final TextStyle? inputTextStyle;
  final bool isPasswordTextField; // 3. Tambahkan flag ini

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureTextInitially = false,
    required this.controller,
    this.readOnly = false,
    this.customLabelStyle,
    this.inputTextStyle,
    this.isPasswordTextField = false, // Defaultnya bukan field password
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureTextCurrent; // 4. State untuk visibilitas password

  @override
  void initState() {
    super.initState();
    _obscureTextCurrent = widget.obscureTextInitially; // Inisialisasi state
  }

  @override
  Widget build(BuildContext context) {
    final defaultReadOnlyLabelStyle = TextStyle(color: Colors.grey[600]);
    final defaultReadOnlyInputStyle = TextStyle(color: Colors.grey[700]);
    final Color iconColor = Colors.grey[600]!; // Warna untuk ikon mata

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: widget.customLabelStyle ?? (widget.readOnly ? defaultReadOnlyLabelStyle : null),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: _obscureTextCurrent, // Gunakan state internal
          readOnly: widget.readOnly,
          style: widget.inputTextStyle ?? (widget.readOnly ? defaultReadOnlyInputStyle : null),
          decoration: InputDecoration(
            hintText: widget.hintText,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.readOnly ? Colors.grey[400]! : Colors.grey,
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.readOnly ? Colors.grey[400]! : Colors.brown,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            filled: widget.readOnly,
            fillColor: widget.readOnly ? Colors.grey[200] : null,
            // 5. Tambahkan suffixIcon jika ini adalah field password
            suffixIcon: widget.isPasswordTextField
                ? IconButton(
                    icon: Icon(
                      _obscureTextCurrent
                          ? PhosphorIcons.eyeClosed() // Ikon mata tertutup
                          : PhosphorIcons.eye(),       // Ikon mata terbuka
                      color: iconColor,
                      size: 20, // Sesuaikan ukuran ikon jika perlu
                    ),
                    splashRadius: 20, // Mengurangi area splash agar lebih rapi
                    onPressed: () {
                      setState(() {
                        _obscureTextCurrent = !_obscureTextCurrent; // Toggle state
                      });
                    },
                  )
                : null, // Tidak ada ikon jika bukan field password
          ),
        ),
      ],
    );
  }
}

// CustomButton tetap sama, tidak perlu diubah
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? iconData;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: iconData != null
          ? ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: onPressed,
              icon: Icon(iconData, color: Colors.white),
              label: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          : ElevatedButton(
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