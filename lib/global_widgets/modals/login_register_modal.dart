import 'package:flutter/material.dart';

import '../../screens/login/email_login_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/login/types.dart';

class LoginRegisterModal extends StatelessWidget {
  const LoginRegisterModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Welcome'),
      content: Text('Please log in or create a new account to continue.'),
      actions: <Widget>[
        TextButton(
          child: Text('Login'),
          onPressed: () => Navigator.of(context).pushNamed(LoginScreen.route),
        ),
        TextButton(
          child: Text('Register'),
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
        title: const Text('Members only'),
        content: Text(message ?? 'This feature is only available to members of this club.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
