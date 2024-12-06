import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/login/email/email_login_screen.dart';
import '../screens/login/email/forgot_password_screen.dart';
import '../screens/login/login_screen.dart';
import 'index.dart';

Route<dynamic> generateLoginRoutes(RouteSettings settings) {
  Widget page = const HomeScreen();
  switch (settings.name) {
    case HomeScreen.route:
      page = const HomeScreen();
      break;
    case LoginScreen.route:
      page = const LoginScreen();
      break;
    case EmailLoginScreen.route:
      page = const EmailLoginScreen();
      break;
    case ForgotPasswordScreen.route:
      final emailFromArgs = settings.arguments as String? ?? '';
      page = ForgotPasswordScreen(email: emailFromArgs);
      break;
  }
  return MyEsRoute(builder: (_) => page, settings: settings);
}
