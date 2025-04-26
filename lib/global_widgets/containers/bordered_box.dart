import 'package:flutter/material.dart';

import '../../theme/index.dart';

class BorderedBox extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color backgroundColor;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final AlignmentGeometry? alignment;

  const BorderedBox({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.borderColor = AppColors.primaryGreen,
    this.padding,
    this.backgroundColor = AppColors.almostWhite,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(border: Border.all(color: borderColor, width: 1), borderRadius: BorderRadius.circular(15), color: backgroundColor),
      padding: padding,
      child: child,
    );
  }
}
