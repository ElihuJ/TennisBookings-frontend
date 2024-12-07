import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import 'config/config.dart';
import 'config/firebase_options.dart';
import 'entry.dart';
import 'types/index.dart';

Future<void> main() async {
  // cspell: disable
  // const reCaptchaKey = '6LcL-pIqAAAAAFst2A5a5euogGwK_SktvTECs3z_';
  // if (kIsWeb) {
  //   bool ready = await GRecaptchaV3.ready("<your Recaptcha site key>"); //--2
  //   print("Is Recaptcha ready? $ready");
  // }

  Config(environment: Environment.dev);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const host = '192.168.86.246';

  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080, sslEnabled: false);
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  await FirebaseStorage.instance.useStorageEmulator(host, 9199);
  FirebaseFunctions.instanceFor(region: Config.functionsRegion).useFunctionsEmulator(host, 5001);

  // await FirebaseAppCheck.instance.activate(webProvider: ReCaptchaV3Provider(reCaptchaKey));

  await Locales.init(SupportedLocales.all);

  runApp(const Entry());
}
