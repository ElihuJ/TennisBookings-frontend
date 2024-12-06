import 'package:flutter/material.dart';

import '../../theme/index.dart';
import '../index.dart';

class TbTextButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final Color color;
  final Color textColor;
  final double height;
  final double width;

  const TbTextButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.color = AppColors.primaryGreen,
    this.textColor = AppColors.white,
    this.height = 60,
    this.width = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: onPressed,
        child: PrettyText(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}

class MyEsButton extends StatelessWidget {
  final Widget child;
  final void Function()? onPressed;
  final Color color;
  final double height;
  final double width;

  const MyEsButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color = AppColors.primaryGreen,
    this.height = 60,
    this.width = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class TbTextButtonWithImage extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final Image image;
  final Color color;
  final Color textColor;
  final double height;
  final double width;

  const TbTextButtonWithImage({
    super.key,
    required this.onPressed,
    required this.text,
    required this.image,
    this.color = AppColors.primaryYellow,
    this.textColor = AppColors.grey,
    this.height = 80,
    this.width = 220,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: PrettyText(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor),
              ),
            ),
            image,
          ],
        ),
      ),
    );
  }
}
