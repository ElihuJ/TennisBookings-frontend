import 'package:flutter/material.dart';

import '../../global_helpers/index.dart';

class PrettyText extends StatelessWidget {
  const PrettyText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines = 1,
    this.fontSize = 16,
    this.color,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int maxLines;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      capitalizeFirstLetter(text),
      style: style ??
          TextStyle(
            fontSize: fontSize,
            color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
      textAlign: textAlign,
      overflow: overflow ?? TextOverflow.ellipsis,
      maxLines: maxLines,
    );
  }
}

class TitleText extends StatelessWidget {
  const TitleText(this.title, {super.key, this.maxLines = 1, this.fontSize = 24.0});
  final String title;
  final int maxLines;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return PrettyText(
      title,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: fontSize,
        overflow: TextOverflow.ellipsis,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
