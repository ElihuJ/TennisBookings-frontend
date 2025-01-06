import 'package:flutter/material.dart';
import 'package:tennisbookings/screens/login/email_login_screen.dart';
import 'package:tennisbookings/screens/login/login_screen.dart';

import '../../screens/login/types.dart';

class LoginSignupModal extends StatelessWidget {
  const LoginSignupModal({super.key});

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
          child: Text('Sign Up'),
          onPressed: () => Navigator.of(context).pushNamed(EmailLoginScreen.route, arguments: ScreenMode.signUp),
        ),
      ],
    );
  }
}

void showLoginSignupModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return LoginSignupModal();
    },
  );
}
