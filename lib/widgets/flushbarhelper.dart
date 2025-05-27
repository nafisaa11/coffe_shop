import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class FlushbarHelper {
  static const flushbarDuration = Duration(seconds: 3);
  static const flushbarAnimDuration = Duration(milliseconds: 500);
  static const flushbarMargin = EdgeInsets.all(8);
  static const flushbarRadius = 8.0;

  static Future<void> show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) async {
    await Flushbar(
      message: message,
      backgroundColor: backgroundColor,
      duration: flushbarDuration,
      flushbarPosition: FlushbarPosition.TOP,
      margin: flushbarMargin,
      borderRadius: BorderRadius.circular(flushbarRadius),
      icon: Icon(icon, color: Colors.white),
      animationDuration: flushbarAnimDuration,
    ).show(context);
  }
}
