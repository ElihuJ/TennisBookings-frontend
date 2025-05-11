import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart';

import 'config/config.dart';
import 'config/firebase_options.dart';
import 'entry.dart';
import 'global_types/index.dart';

Future<void> main() async {
  Config(environment: Environment.prod);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kIsWeb) {
    WebStripe.instance.initialise(publishableKey: Config().publishableKey);
  } else {
    Stripe.publishableKey = Config().publishableKey;
  }

  await Locales.init(SupportedLocales.all);

  runApp(const Entry());
}
