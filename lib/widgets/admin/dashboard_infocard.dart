import 'package:flutter/material.dart';

class DashboardInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color? textColor;

  const DashboardInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    this.iconColor = Colors.white,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color defaultTextColor =
        ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
            ? Colors.white
            : Colors.black;
    final Color currentTextColor = textColor ?? defaultTextColor;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: backgroundColor,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16, // Reduced horizontal padding
          vertical: 12,
        ), // Reduced vertical padding),
        // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 22, // Reduced font size for better fit
                      fontWeight: FontWeight.bold,
                      color: currentTextColor,
                      height: 1.2, // Tighter line height
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 4), // Reduced spacing
                Icon(icon, color: iconColor, size: 24), // Reduced icon size
              ],
            ),
            const SizedBox(height: 8), // Fixed spacing instead of Spacer
            Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14, // Slightly reduced
                    fontWeight: FontWeight.w500,
                    color: currentTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
