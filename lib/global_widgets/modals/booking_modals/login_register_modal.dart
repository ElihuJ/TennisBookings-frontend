import 'package:flutter/material.dart';

import '../../../screens/login/email_login_screen.dart';
import '../../../screens/login/login_screen.dart';
import '../../../screens/login/types.dart';
import '../../../theme/index.dart';
import '../../index.dart';

class LoginRegisterModal extends StatelessWidget {
  const LoginRegisterModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: PrettyText('Welcome'),
      content: PrettyText('Please log in or create a new account to continue.'),
      actions: <Widget>[
        TbTextButton(
          text: 'Login',
          onPressed: () => Navigator.of(context).pushNamed(LoginScreen.route),
          color: AppColors.secondaryGreen,
        ),
        TbTextButton(
          text: 'Register',
          color: AppColors.darkGreen,
          onPressed: () => Navigator.of(context).pushNamed(EmailLoginScreen.route, arguments: ScreenMode.register),
        ),
      ],
    );
  }
}

void showLoginRegisterModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return LoginRegisterModal();
    },
  );
}

void showOnlyMembersModal({required BuildContext context, String? message}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const TitleText('Members only', textAlign: TextAlign.center),
        content: PrettyText(message ?? 'This feature is only available to members of this club.'),
        actions: <Widget>[
          TextButton(
            child: const PrettyText('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
