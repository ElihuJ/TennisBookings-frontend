import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../../models/firestore/fields/firebase_config_main_fields.dart';

@immutable
class FirebaseConfig extends MapView<String, dynamic> {
  final int? majorVersion;
  final int? minorVersion;
  final int? patchVersion;
  final int? buildNumber;
  final bool loaded = false;

  FirebaseConfig(
      {required this.majorVersion, required this.minorVersion, required this.patchVersion, required this.buildNumber, required bool loaded})
      : super({
          FirebaseConfigMainFields.majorVersion: majorVersion,
          FirebaseConfigMainFields.minorVersion: minorVersion,
          FirebaseConfigMainFields.patchVersion: patchVersion,
          FirebaseConfigMainFields.buildNumber: buildNumber,
        });

  FirebaseConfig.empty() : this(majorVersion: null, minorVersion: null, patchVersion: null, buildNumber: null, loaded: false);

  factory FirebaseConfig.fromJson(FirestoreResponse json) {
    try {
      // * ================================== Required Props ==================================
      final majorVersion =
          verifyNotRequiredProp<int>(prop: json[FirebaseConfigMainFields.majorVersion], propName: FirebaseConfigMainFields.majorVersion);
      final minorVersion =
          verifyNotRequiredProp<int>(prop: json[FirebaseConfigMainFields.minorVersion], propName: FirebaseConfigMainFields.minorVersion);
      final patchVersion =
          verifyNotRequiredProp<int>(prop: json[FirebaseConfigMainFields.patchVersion], propName: FirebaseConfigMainFields.patchVersion);
      final buildNumber =
          verifyNotRequiredProp<int>(prop: json[FirebaseConfigMainFields.buildNumber], propName: FirebaseConfigMainFields.buildNumber);

      final propsList = [
        FirebaseConfigMainFields.majorVersion,
        FirebaseConfigMainFields.minorVersion,
        FirebaseConfigMainFields.patchVersion,
        FirebaseConfigMainFields.buildNumber
      ];

      verifyProps(json, propsList);

      return FirebaseConfig(
          majorVersion: majorVersion, minorVersion: minorVersion, patchVersion: patchVersion, buildNumber: buildNumber, loaded: true);
    } catch (e) {
      e.tbLogger('ERROR CONSTRUCTING CONFIG', DebugLevel.error);
      return FirebaseConfig.empty();
    }
  }

  FirestorePayload toJson() => {
        FirebaseConfigMainFields.majorVersion: majorVersion,
        FirebaseConfigMainFields.minorVersion: minorVersion,
        FirebaseConfigMainFields.patchVersion: patchVersion,
        FirebaseConfigMainFields.buildNumber: buildNumber
      };

  @override
  String toString() {
    return '==================== Config ==================== \n'
        'majorVersion: $majorVersion\n'
        'minorVersion: $minorVersion\n'
        'patchVersion: $patchVersion\n'
        'buildNumber: $buildNumber\n'
        ')';
  }
}
