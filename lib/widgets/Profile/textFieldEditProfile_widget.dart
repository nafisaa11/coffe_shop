// widgets/textFieldProfile_widget.dart
import 'package:flutter/material.dart';

class TextFieldProfile extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?)? validator;
  final bool readOnly;
  final bool isPassword;
  final Widget? suffixIcon;

  const TextFieldProfile({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.icon,
    this.validator,
    this.readOnly = false,
    this.isPassword = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            readOnly: readOnly,
            obscureText: isPassword,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: readOnly ? Colors.grey.shade600 : const Color(0xFF2C2C2C),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade400, // Faded hint text color
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  icon,
                  color:
                      readOnly
                          ? Colors.grey.shade400
                          : const Color(0xFFD07C3D).withOpacity(0.7),
                  size: 20,
                ),
              ),
              suffixIcon:
                  suffixIcon != null
                      ? Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: suffixIcon,
                      )
                      : null,
              filled: true,
              fillColor: readOnly ? Colors.grey.shade100 : Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFD07C3D),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}