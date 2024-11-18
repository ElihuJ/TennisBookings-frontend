import 'package:flutter/material.dart';

import '../../theme/index.dart';

class BorderedBox extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const BorderedBox({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.borderColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? AppColors.primaryBrown, width: 1),
          borderRadius: BorderRadius.circular(15),
          color: AppColors.almostWhite),
      padding: padding,
      child: child,
    );
  }
}
