import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:flutter_localizations/flutter_localizations.dart';

import '../theme/index.dart';
import '../types/index.dart';

// * SINGLETON
class Config {
  static Config? _instance;

  factory Config({Environment environment = Environment.dev}) {
    return _instance ??= Config._(environment: environment);
  }

  Config._({this.environment}) : envString = environment == Environment.prod ? 'Prod' : environment.toString() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  final Environment? environment;
  final String envString;
  static ThemeData theme = selectedTheme;

  // ! MAXIMUMS
  static const recipeBatchSize = 30;
  static const maxNotesPerBean = 7;
  static const maxBeans = 3;
  static const maxBaskets = 2;
  static const maxGrinders = 2;
  static const maxMachines = 2;
  static const commentsMaxLength = 200;
  static const aiCommentsMaxLength = 1000;

  // * VERSIONING
  static const majorVersion = 1;
  static const minorVersion = 5;
  static const patchVersion = 7;
  static const buildNumber = 67;

  static const versionString = '$majorVersion.$minorVersion.$patchVersion ($buildNumber)';

  // * NOTIFIER DURATIONS
  static const toastDuration = Duration(seconds: 3);
  static const defaultNotifierDuration = Duration(milliseconds: 1500);
  static const mediumNotifierDuration = Duration(seconds: 3);
  static const longNotifierDuration = Duration(seconds: 5);

  // * SOCIALS
  static const youtubeUrl = 'https://www.youtube.com/channel/UCwHQFrxWkOcX9m8Pm34-r6Q';
  static const supportEmail = 'support@myespresso.club';
  static const defaultSupportSubject = 'Support Request';

  // * LEGAL URLS
  static const privacyPolicyUrl = 'https://myespresso.club/privacy-policy';
  static const appleEulaUrl = 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

  // ^ ================== APP CONFIG ==================
  static const appName = "Tennis Bookings";
  static const functionsRegion = "australia-southeast1";

  static const appleSubscriptionIds = {'myespresso_premium_monthly', 'myespresso_premium_yearly'};

  static const androidSubscriptionIds = 'myespresso_base_subscription';

  static const appleSubscriptionsUrl = 'https://apps.apple.com/account/subscriptions';
  static const androidSubscriptionsUrl = 'https://play.google.com/store/account/subscriptions';

  // static const supportedLocales = [
  //   Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
  //   Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
  // ];
  // static const localizationsDelegates = [
  //   GlobalMaterialLocalizations.delegate,
  //   GlobalWidgetsLocalizations.delegate,
  //   GlobalCupertinoLocalizations.delegate
  // ];

  @override
  String toString() => 'Config: $envString environment is running'
      '\nappName: $appName'
      '\nfunctionsRegion: $functionsRegion';
  // '\nsupportedLocales: $supportedLocales'
  // '\nlocalizationsDelegates: $localizationsDelegates';
}
