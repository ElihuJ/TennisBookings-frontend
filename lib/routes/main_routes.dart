import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import 'index.dart';

Route<dynamic> generateLoginRoutes(RouteSettings settings) {
  Widget page = const HomeScreen();
  switch (settings.name) {
    case HomeScreen.route:
      page = const HomeScreen();
      break;
  }
  return MyEsRoute(builder: (_) => page, settings: settings);
}
