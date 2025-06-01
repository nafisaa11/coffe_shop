// lib/widgets/customtextfield.dart (atau path yang sesuai)
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// Definisi Class CustomTextField
class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final bool obscureTextInitially;
  final TextEditingController controller;
  final bool readOnly;
  final TextStyle? customLabelStyle;
  final TextStyle? inputTextStyle;
  final bool isPasswordTextField;
  final String? Function(String?)? validator;
  final IconData? prefixIcon; // 👈 1. TAMBAHKAN variabel prefixIcon
  final TextInputType? keyboardType; // 👈 2. TAMBAHKAN variabel keyboardType

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureTextInitially = false,
    required this.controller,
    this.readOnly = false,
    this.customLabelStyle,
    this.inputTextStyle,
    this.isPasswordTextField = false,
    this.validator,
    this.prefixIcon, // 👈 3. TAMBAHKAN di konstruktor
    this.keyboardType, // 👈 4. TAMBAHKAN di konstruktor
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureTextCurrent;

  @override
  void initState() {
    super.initState();
    _obscureTextCurrent = widget.obscureTextInitially;
  }

  @override
  Widget build(BuildContext context) {
    final defaultReadOnlyLabelStyle = TextStyle(color: Colors.grey[600]);
    final defaultReadOnlyInputStyle = TextStyle(color: Colors.grey[700]);
    final Color iconColor = Colors.grey[600]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style:
              widget.customLabelStyle ??
              (widget.readOnly ? defaultReadOnlyLabelStyle : null),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureTextCurrent,
          readOnly: widget.readOnly,
          style:
              widget.inputTextStyle ??
              (widget.readOnly ? defaultReadOnlyInputStyle : null),
          keyboardType:
              widget.keyboardType, // 👈 5. GUNAKAN keyboardType di sini
          decoration: InputDecoration(
            hintText: widget.hintText,
            // _iconColor dari PhosphorIcons bisa di-pass sebagai widget jika Anda mau
            // tapi jika hanya IconData, kita buat Icon widget di sini.
            prefixIcon:
                widget.prefixIcon !=
                        null // 👈 6. GUNAKAN prefixIcon di sini
                    ? Icon(
                      widget.prefixIcon,
                      color:
                          widget.readOnly
                              ? Colors.grey[500]
                              : Colors.brown.shade400, // Sesuaikan warna ikon
                      size: 20, // Sesuaikan ukuran ikon
                    )
                    : null,
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
            suffixIcon:
                widget.isPasswordTextField
                    ? IconButton(
                      icon: Icon(
                        _obscureTextCurrent
                            ? PhosphorIcons.eyeClosed()
                            : PhosphorIcons.eye(),
                        color: iconColor,
                        size: 20,
                      ),
                      splashRadius: 20,
                      onPressed: () {
                        setState(() {
                          _obscureTextCurrent = !_obscureTextCurrent;
                        });
                      },
                    )
                    : null,
          ),
          validator: widget.validator,
        ),
      ],
    );
  }
}

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
      child:
          iconData != null
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
