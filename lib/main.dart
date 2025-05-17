import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'config/config.dart';
import 'entry.dart';
import 'global_types/index.dart';

Future<void> main() async {
  final env = _getEnvironment();

  Config(environment: env);
  await Firebase.initializeApp(options: Config().firebaseOptions);

  if (env == Environment.dev) await _initEmulators();
  Stripe.publishableKey = Config().publishableKey;

  await Locales.init(SupportedLocales.all);

  runApp(const Entry());
}

Environment _getEnvironment() {
  final envString = const String.fromEnvironment('ENV');
  final env = Environment.values.firstWhereOrNull(
    (e) => e.name == envString,
  );

  if (env == null) {
    throw Exception('Invalid environment: $envString');
  }

  return env;
}

Future<void> _initEmulators() async {
  const host = '192.168.86.246';

  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080, sslEnabled: false);
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  await FirebaseStorage.instance.useStorageEmulator(host, 9199);
  FirebaseFunctions.instanceFor(region: Config.functionsRegion).useFunctionsEmulator(host, 5001);
}
