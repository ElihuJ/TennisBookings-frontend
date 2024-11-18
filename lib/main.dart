import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import './helpers/index.dart';

import 'config/config.dart';
import 'config/firebase_options.dart';
import 'entry.dart';
import 'types/index.dart';

Future<void> main() async {
  // cspell: disable
  const reCaptchaKey = '&a2NEe7aTmx@M66L#TTVGNC695bAm';
  ''.myEsLogger('main');
  Config(environment: Environment.prod);
  ''.myEsLogger('main2');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  ''.myEsLogger('main3');
  await FirebaseAppCheck.instance.activate(webProvider: ReCaptchaV3Provider(reCaptchaKey));

  ''.myEsLogger('main4');
  await Locales.init(SupportedLocales.all);
  ''.myEsLogger('main5');

  runApp(const Entry());
}
