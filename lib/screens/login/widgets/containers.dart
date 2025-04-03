import 'dart:ui';

import 'package:flutter/material.dart';

class ContainerWithBackground extends StatelessWidget {
  const ContainerWithBackground({super.key, required this.child, required this.imagePath});

  final Widget child;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath, // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
