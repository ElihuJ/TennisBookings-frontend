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
    this.fontSize = 20.0,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int maxLines;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      capitalizeFirstLetter(text),
      style: style ??
          TextStyle(
            fontSize: fontSize,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
      textAlign: textAlign,
      overflow: overflow ?? TextOverflow.visible,
      maxLines: maxLines,
    );
  }
}

class TitleText extends StatelessWidget {
  const TitleText(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return PrettyText(
      title,
      style: const TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
