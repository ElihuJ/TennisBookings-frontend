import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../global_types/index.dart';

import '../theme/index.dart';
import 'firebase_options.dart';
import 'firebase_options_uat..dart';
import 'google_sign_in.dart';

// * SINGLETON
class Config {
  static Config? _instance;
  final Environment? environment;
  final String envString;
  static ThemeData theme = selectedTheme;
  late final String _publishableKey;
  late final FirebaseOptions _firebaseOptions;
  late final GoogleSignIn _googleSignInConfig;

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

    if (environment == Environment.uat) {
      _publishableKey = _devPublishableKey;
      _firebaseOptions = UatDefaultFirebaseOptions.currentPlatform;
      _googleSignInConfig = GoogleSignIn(scopes: GoogleSignInConfig.scopes, clientId: GoogleSignInConfig.uatClientId);
    } else if (environment == Environment.prod || environment == Environment.dev) {
      _publishableKey = _prodPublishableKey;
      _firebaseOptions = ProdDefaultFirebaseOptions.currentPlatform;
      _googleSignInConfig = GoogleSignIn(scopes: GoogleSignInConfig.scopes, clientId: GoogleSignInConfig.clientId);
    }
  }

  // * VERSIONING
  static const majorVersion = 1;
  static const minorVersion = 2;
  static const patchVersion = 8;
  static const buildNumber = 43;
  static const latestNotes = 'Added notification bubble on "My Invites" tab';

  static const versionString = '$majorVersion.$minorVersion.$patchVersion ($buildNumber)';

  // * NOTIFIER DURATIONS
  static const toastDuration = Duration(seconds: 3);
  static const defaultNotifierDuration = Duration(milliseconds: 1500);
  static const mediumNotifierDuration = Duration(seconds: 3);
  static const longNotifierDuration = Duration(seconds: 5);

  // ^ ================== APP CONFIG ==================
  static const appName = "Tennis Bookings";
  static const functionsRegion = "australia-southeast2";
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
  get firebaseOptions => _firebaseOptions;
  get googleSignInConfig => _googleSignInConfig;

  @override
  String toString() => 'Config: $envString environment is running'
      '\nappName: $appName'
      '\nfunctionsRegion: $functionsRegion';
  // '\nsupportedLocales: $supportedLocales'
  // '\nlocalizationsDelegates: $localizationsDelegates';
}
