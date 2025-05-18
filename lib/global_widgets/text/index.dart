import 'package:flutter/material.dart';

import '../../global_helpers/index.dart';

class PrettyText extends StatelessWidget {
  const PrettyText(this.text,
      {super.key, this.style, this.textAlign, this.overflow, this.maxLines, this.fontSize, this.color, this.additionalSize = 0});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? fontSize;
  final Color? color;
  final double additionalSize;

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);
    final defaultFontSize = getFontSize(mobileView) + additionalSize;
    return Text(
      capitalizeFirstLetter(text),
      style: style ??
          TextStyle(
            fontSize: fontSize ?? defaultFontSize,
            color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
      textAlign: textAlign,
      overflow: overflow ?? TextOverflow.ellipsis,
      maxLines: maxLines ?? 2,
    );
  }
}

class TitleText extends StatelessWidget {
  const TitleText(this.text,
      {super.key, this.style, this.textAlign, this.overflow, this.maxLines, this.fontSize, this.color, this.additionalSize = 0});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? fontSize;
  final Color? color;
  final double additionalSize;

  @override
  Widget build(BuildContext context) {
    return PrettyText(
      text,
      additionalSize: 6,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
