import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../global_types/index.dart';

import '../theme/index.dart';

// * SINGLETON
class Config {
  static Config? _instance;
  late final String _publishableKey;
  final Environment? environment;
  final String envString;
  static ThemeData theme = selectedTheme;

  factory Config({Environment environment = Environment.dev}) {
    return _instance ??= Config._(environment: environment);
  }

  Config._({this.environment}) : envString = environment.toString() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (environment != Environment.prod) {
      _publishableKey = _devPublishableKey;
    } else if (environment == Environment.prod) {
      _publishableKey = _prodPublishableKey;
    }
  }

  // * VERSIONING
  static const majorVersion = 1;
  static const minorVersion = 2;
  static const patchVersion = 3;
  static const buildNumber = 34;

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
  static const bookingFutureLimit = 2 * 4 * 7 * 24 * 60 * 60 * 1000; // * 2 months in milliseconds// * Keep synced with BOOKING_FUTURE_LIMIT
  static const minDuration = (3600 / 2) * 1000; // 30 minutes // * Keep synced with minDurationMinutes
  static const minDurationMinutesString = 30;

  static const utrMaxRating = 16;
  static const utrMinRating = 0;

  // ^ ================== STRIPE CONFIG ==================
  // cspell: disable
  static const _devPublishableKey = "pk_test_51RKduZPBFN3dQsNnbymgLQB6Tpu02JbAge53xoOAmV7WRj0bD5bHid0PXSJ2Ic5l93oLAVpv1W7MwxSKBssaCcGA00GBLL9eHf";
  static const _prodPublishableKey = "pk_live_51RKduQAEUEBEyE19Q1YKTZlSOB0ytptc6knpktcvOerL6VNK9He5CbaHQKXMtqRJnJdoOVIeVtT7e74IphvSpWF1005OdOynTD";
  get publishableKey => _publishableKey;

  @override
  String toString() => 'Config: $envString environment is running'
      '\nappName: $appName'
      '\nfunctionsRegion: $functionsRegion';
  // '\nsupportedLocales: $supportedLocales'
  // '\nlocalizationsDelegates: $localizationsDelegates';
}
