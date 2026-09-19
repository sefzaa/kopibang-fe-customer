import 'package:flutter/material.dart';

class GlobalHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool centerText;

  const GlobalHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    this.centerText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centerText ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Logo Section
        Row(
          mainAxisAlignment: centerText ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: const [
            Icon(Icons.coffee_outlined, color: Color(0xFF3E2723), size: 24),
            SizedBox(width: 8),
            Text(
              '111 Coffee',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3E2723),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        // Title & Subtitle Section
        Text(
          title,
          textAlign: centerText ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: centerText ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}