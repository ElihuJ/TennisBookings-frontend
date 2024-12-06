import 'package:flutter/material.dart';

import '../../../../widgets/index.dart';

const double _margin = 15;

class TextArea extends StatelessWidget {
  const TextArea({super.key, required this.text, this.isTitle = false});

  final String text;
  final bool isTitle;

  @override
  Widget build(BuildContext context) {
    final style = isTitle ? Theme.of(context).textTheme.titleLarge : Theme.of(context).textTheme.titleSmall;
    return Container(
      margin: const EdgeInsets.only(bottom: _margin),
      child: PrettyText(text, style: style),
    );
  }
}
