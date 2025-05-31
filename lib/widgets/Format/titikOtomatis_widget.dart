import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('id');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String cleaned = newValue.text.replaceAll('.', '').replaceAll(',', '');

    if (cleaned.isEmpty) return newValue.copyWith(text: '');

    int? number = int.tryParse(cleaned);
    if (number == null) return oldValue;

    String newText = _formatter.format(number);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
