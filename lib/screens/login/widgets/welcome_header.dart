import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../assets/index.dart';
import '../../../strings/login/index.dart';
import 'text_area.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({
    super.key,
    required this.isLogin,
  });

  final bool isLogin;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          logoPgn,
          width: 300,
        ),
      ),
      SizedBox(height: 20),
      TextArea(
        text: isLogin ? context.localeString(EmailLoginScreenStrings.login) : context.localeString(EmailLoginScreenStrings.register),
        isTitle: true,
      ),
      TextArea(
          text: isLogin ? context.localeString(EmailLoginScreenStrings.welcomeBack) : context.localeString(EmailLoginScreenStrings.justAFewThings))
    ]);
  }
}
