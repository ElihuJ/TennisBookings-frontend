import 'package:flutter/material.dart';

import '../models/index.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/club_details/club_details_screen.dart';
import '../screens/payments/membership_payment_screen.dart';
import '../screens/payments/casual_payment_screen.dart';
import '../screens/payments/payment_result_screen.dart';
import '../screens/find_clubs/find_clubs_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login/email_login_screen.dart';
import '../screens/login/forgot_password_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/login/types.dart';
import '../screens/my_invites/my_invites_screen.dart';
import '../screens/profile/profile_screen.dart';
import 'helper.dart';
import 'index.dart';

Route<dynamic> generateLoginRoutes(RouteSettings settings) {
  Widget page = const HomeScreen();

  final settingUri = Uri.parse(settings.name ?? '');

  final queryParams = QueryParams(settingUri.queryParameters);
  String path = settingUri.path;

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
    case MyInvitesScreen.route:
      page = const MyInvitesScreen();
      break;
    case ProfileScreen.route:
      page = const ProfileScreen();
      break;
    case CalendarScreen.route:
      final clubSelectedQueryParams = ClubSelectedQueryParams(queryParams.queryParams);
      page = CalendarScreen(clubSelectedQueryParams: clubSelectedQueryParams);
      break;
    case ClubDetailsScreen.route:
      final clubSelectedQueryParams = ClubSelectedQueryParams(queryParams.queryParams);
      page = ClubDetailsScreen(clubSelectedQueryParams: clubSelectedQueryParams);
      break;
    case MembershipPaymentScreen.route:
      final clubSelectedQueryParams = ClubSelectedQueryParams(queryParams.queryParams);
      page = MembershipPaymentScreen(clubSelectedQueryParams: clubSelectedQueryParams);
      break;

    case CasualPaymentScreen.route:
      final booking = settings.arguments as Booking;
      page = CasualPaymentScreen(booking: booking);
      break;
    case PaymentResultScreen.route:
      final uriQuery = Uri.base.queryParameters;
      final baseQueryParams = QueryParams({...uriQuery, ...queryParams.queryParams});
      final stripeParams = StripePaymentQueryParams(baseQueryParams.queryParams);

      page = PaymentResultScreen(params: stripeParams);
      break;
  }
  return MyEsRoute(
    builder: (_) => page,
    settings: settings,
  );
}
