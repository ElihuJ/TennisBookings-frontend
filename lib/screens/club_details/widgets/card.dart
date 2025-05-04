import 'package:flutter/material.dart';

import '../../../theme/index.dart';

class CardTemplate extends StatelessWidget {
  const CardTemplate({super.key, required this.child, this.backgroundColor});

  static double cardsWidth = 500.0;

  final Color? backgroundColor; // Optional background color
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6, // Increased elevation to make it stand out
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // More rounded corners for emphasis
      ),
      child: Container(
        width: cardsWidth, // Set a fixed width for consistency with other cards
        padding: const EdgeInsets.all(20.0), // Increased padding for a more prominent look
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primaryGreen, // Use the provided background color or default to card color
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}
