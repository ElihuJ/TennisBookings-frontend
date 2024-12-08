import 'package:flutter/material.dart';

import '../../global_helpers/index.dart';

class PrettyText extends StatelessWidget {
  const PrettyText(this.text, {super.key, this.style, this.textAlign, this.overflow, this.maxLines = 1});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      capitalizeFirstLetter(text),
      style: style,
      // textScaler: TextScaler.linear(scaleText(context)),
      textAlign: textAlign,
      overflow: overflow ?? TextOverflow.visible,
      maxLines: maxLines,
    );
  }
}
