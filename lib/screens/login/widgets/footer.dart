import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../strings/login/index.dart';
import '../../../theme/colors.dart';
import '../forgot_password_screen.dart';
import '../types.dart';

class Footer extends StatelessWidget {
  const Footer({
    super.key,
    required this.isLogin,
    required this.toggleScreenMode,
    required this.screenMode,
    required this.email,
  });

  final bool isLogin;
  final void Function() toggleScreenMode;
  final ScreenMode screenMode;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isLogin)
          TextButton(
            onPressed: () => Navigator.pushNamed(context, ForgotPasswordScreen.route, arguments: email),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(
              context.localeString(EmailLoginScreenStrings.forgotPassword),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: toggleScreenMode,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryGreen,
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: Text(
            isLogin
                ? context.localeString(EmailLoginScreenStrings.dontHaveAnAccount)
                : context.localeString(EmailLoginScreenStrings.alreadyHaveAnAccount),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
