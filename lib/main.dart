import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import 'config/config.dart';
import 'config/firebase_options.dart';
import 'entry.dart';
import 'types/index.dart';

Future<void> main() async {
  // cspell: disable
  const reCaptchaKey = '6LcL-pIqAAAAAFst2A5a5euogGwK_SktvTECs3z_';
  Config(environment: Environment.prod);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(webProvider: ReCaptchaV3Provider(reCaptchaKey));

  await Locales.init(SupportedLocales.all);

  runApp(const Entry());
}
