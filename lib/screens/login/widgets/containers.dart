import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/colors.dart';

class ContainerWithBackground extends StatelessWidget {
  const ContainerWithBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _BackgroundPainter()),
          ),
          child,
        ],
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base diagonal gradient — mint top-left → near-white bottom-right
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.mintLight, AppColors.mintBase, AppColors.white],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Large green bloom — top-left
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [AppColors.courtGreen.withValues(alpha: 0.18), AppColors.transparent],
        ).createShader(Rect.fromCircle(
          center: Offset.zero,
          radius: size.shortestSide * 1.1,
        )),
    );

    // Soft teal bloom — bottom-right
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [AppColors.tealGreen.withValues(alpha: 0.12), AppColors.transparent],
        ).createShader(Rect.fromCircle(
          center: Offset(size.width, size.height),
          radius: size.shortestSide * 0.85,
        )),
    );

    // Decorative court arcs — bottom-left corner
    final arcPaint = Paint()
      ..color = AppColors.courtGreen.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final arcCenter = Offset(0, size.height);
    for (final r in [size.shortestSide * 0.22, size.shortestSide * 0.38, size.shortestSide * 0.54]) {
      canvas.drawArc(Rect.fromCircle(center: arcCenter, radius: r), -math.pi / 2, math.pi / 2, false, arcPaint);
    }

    // Decorative court arcs — top-right corner (lighter)
    final arcPaint2 = Paint()
      ..color = AppColors.courtGreen.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final arcCenter2 = Offset(size.width, 0);
    for (final r in [size.shortestSide * 0.18, size.shortestSide * 0.32]) {
      canvas.drawArc(Rect.fromCircle(center: arcCenter2, radius: r), math.pi / 2, math.pi / 2, false, arcPaint2);
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) => false;
}
