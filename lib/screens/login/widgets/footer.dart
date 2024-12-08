import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../strings/login/index.dart';
import '../forgot_password_screen.dart';
import '../types.dart';
import 'text_area.dart';

class Footer extends StatelessWidget {
  const Footer({super.key, required this.isLogin, required this.toggleScreenMode, required this.screenMode, required this.email});

  final bool isLogin;
  final void Function() toggleScreenMode;
  final ScreenMode screenMode;
  final String email;

  @override
  Widget build(BuildContext context) {
    return isLogin
        ? InkWell(
            onTap: () {
              Navigator.pushNamed(context, ForgotPasswordScreen.route, arguments: email);
            },
            child: TextArea(text: context.localeString(EmailLoginScreenStrings.forgotPassword)),
          )
        : Container();
  }
}
