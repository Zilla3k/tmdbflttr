import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final double iconSize;
  final TextStyle textStyle;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = const Color(0xFF92929D),
    this.iconSize = 16,
    this.textStyle = const TextStyle(
      color: Color(0xFF92929D),
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        SizedBox(width: 4),
        Text(text, style: textStyle),
      ],
    );
  }
}
