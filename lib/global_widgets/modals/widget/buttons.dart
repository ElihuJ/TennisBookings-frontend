import 'package:flutter/material.dart';

import '../../../theme/index.dart';

class TbButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final Color color;

  const TbButton({super.key, required this.text, this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        backgroundColor: WidgetStatePropertyAll(color),
        textStyle: WidgetStatePropertyAll(
          TextStyle(foreground: Paint()..color = AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      child: Text(text),
    );
  }
}
