import 'package:flutter/material.dart';

class GlobalHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onProfileTap;

  const GlobalHeader({
    super.key,
    this.title = 'KopiBang',
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryBrown = const Color(0xFF3C2A21);
    return Row(
      children: [
        Icon(Icons.coffee_outlined, color: primaryBrown, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryBrown,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onProfileTap,
          child: const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Admin&background=3C2A21&color=fff'),
          ),
        ),
      ],
    );
  }
}