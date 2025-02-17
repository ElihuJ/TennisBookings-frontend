import 'package:flutter/material.dart';

// import '../global_helpers/index.dart';
import '../screens/club/schedule_screen.dart';
import '../screens/find_clubs/find_clubs_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login/email_login_screen.dart';
import '../screens/login/forgot_password_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/login/types.dart';
import 'helper.dart';
import 'index.dart';

Route<dynamic> generateLoginRoutes(RouteSettings settings) {
  Widget page = const HomeScreen();
  final settingUri = Uri.parse(settings.name ?? '');
  final QueryParams queryParams = QueryParams(settingUri.queryParameters);
  final path = settingUri.path;
  // path.tbLogger('PATH');
  // queryParams.toString().tbLogger('QUERY PARAMS');
  switch (path) {
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
    case ScheduleScreen.route:
      final clubSelectedQueryParams = ClubSelectedQueryParams(queryParams.queryParams);
      page = ScheduleScreen(clubSelectedQueryParams: clubSelectedQueryParams);
      break;
  }
  return MyEsRoute(
    builder: (_) => page,
    settings: settings,
  );
}
