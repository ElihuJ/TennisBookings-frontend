import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../screens/login/email_login_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/login/types.dart';
import '../../strings/index.dart';
import '../../theme/index.dart';

class LoginRegisterButton extends StatelessWidget {
  const LoginRegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed(LoginScreen.route),
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            overlayColor: Colors.white.withValues(alpha: 0.12),
          ),
          child: Text(
            context.localeString(GeneralStrings.headerLogin),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 6),
        FilledButton(
          onPressed: () => Navigator.of(context)
              .pushNamed(EmailLoginScreen.route, arguments: ScreenMode.register),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.darkGreen,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            context.localeString(GeneralStrings.headerRegister),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
