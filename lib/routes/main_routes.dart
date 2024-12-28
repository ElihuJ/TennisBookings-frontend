import 'package:flutter/material.dart';

import '../screens/find_clubs/find_clubs_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login/email_login_screen.dart';
import '../screens/login/forgot_password_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/login/types.dart';
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
      final screenMode = settings.arguments as ScreenMode;
      page = EmailLoginScreen(screenMode: screenMode);
      break;
    case ForgotPasswordScreen.route:
      final emailFromArgs = settings.arguments as String? ?? '';
      page = ForgotPasswordScreen(email: emailFromArgs);
      break;
    case FindClubsScreen.route:
      page = const FindClubsScreen();
      break;
  }
  return MyEsRoute(builder: (_) => page, settings: settings);
}
