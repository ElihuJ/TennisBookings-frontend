import 'package:flutter/material.dart';

import '../../helpers/index.dart';
import '../index.dart';

class LoginButton extends StatelessWidget {
  final void Function() onTap;
  final String text;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final dynamic icon;
  final FontWeight fontWeight;

  const LoginButton({
    super.key,
    required this.onTap,
    required this.text,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.borderColor = Colors.black,
    this.fontWeight = FontWeight.normal,
    Widget? this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthPercent(percentage: 30, context),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: 2.5,
        ),
      ),
      height: 65,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Ink(color: backgroundColor, child: icon),
            SizedBox(width: widthPercent(percentage: 1, context)),
            PrettyText(
              text,
              style: TextStyle(fontWeight: fontWeight, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
