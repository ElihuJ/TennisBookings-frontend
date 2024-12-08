import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

// import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';

import 'config/config.dart';
import 'config/firebase_options.dart';
import 'entry.dart';
import 'global_types/index.dart';

Future<void> main() async {
  // cspell: disable
  // const reCaptchaKey = '6LcL-pIqAAAAAFst2A5a5euogGwK_SktvTECs3z_';
  Config(environment: Environment.prod);
  // if (kIsWeb) {
  //   bool ready = await GRecaptchaV3.ready("<your Recaptcha site key>"); //--2
  //   print("Is Recaptcha ready? $ready");
  // }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await FirebaseAppCheck.instance.activate(webProvider: ReCaptchaV3Provider(reCaptchaKey));

  await Locales.init(SupportedLocales.all);

  runApp(const Entry());
}
