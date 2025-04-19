import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../global_types/index.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

import '../theme/index.dart';

// * SINGLETON
class Config {
  static Config? _instance;

  factory Config({Environment environment = Environment.dev}) {
    return _instance ??= Config._(environment: environment);
  }

  Config._({this.environment}) : envString = environment.toString() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  final Environment? environment;
  final String envString;
  static ThemeData theme = selectedTheme;

  // * VERSIONING
  static const majorVersion = 0;
  static const minorVersion = 0;
  static const patchVersion = 2;
  static const buildNumber = 2;

  static const versionString = '$majorVersion.$minorVersion.$patchVersion ($buildNumber)';

  // * NOTIFIER DURATIONS
  static const toastDuration = Duration(seconds: 3);
  static const defaultNotifierDuration = Duration(milliseconds: 1500);
  static const mediumNotifierDuration = Duration(seconds: 3);
  static const longNotifierDuration = Duration(seconds: 5);

  // ^ ================== APP CONFIG ==================
  static const appName = "Tennis Bookings";
  static const functionsRegion = "australia-southeast1";
  static const maxBookingDuration = 3600 * 1.5 * 1000; // 1.5 hours in milliseconds // * Keep synced with maxBookingHours
  static const maxBookingHoursString = 1.5;
  static const minDuration = (3600 / 2) * 1000; // 30 minutes // * Keep synced with minDurationMinutes
  static const minDurationMinutesString = 30;

  static const utrMaxRating = 16;
  static const utrMinRating = 0;

  @override
  String toString() => 'Config: $envString environment is running'
      '\nappName: $appName'
      '\nfunctionsRegion: $functionsRegion';
  // '\nsupportedLocales: $supportedLocales'
  // '\nlocalizationsDelegates: $localizationsDelegates';
}
