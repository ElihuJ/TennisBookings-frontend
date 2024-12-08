import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../../models/index.dart';

final defaultId = getUuid();
const defaultName = 'Problem loading user';
const defaultEmail = 'email';

@immutable
class User extends MapView<String, dynamic> {
  final String uid;
  final String name;
  final String email;
  final int createdAt;

  User({
    this.name = '',
    this.uid = '',
    this.email = '',
    this.createdAt = 0,
  }) : super({
          UserFields.uid: uid,
          UserFields.name: name,
          UserFields.email: email,
          UserFields.createdAt: createdAt,
        });

  User.empty() : this();

  factory User.fromJson(FirestoreResponse json) {
    try {
      // * ================================== Required Props ==================================
      final uid = verifyRequiredProp<String>(prop: json[UserFields.uid], propName: UserFields.uid, defaultValue: defaultId);
      final name = verifyRequiredProp<String>(prop: json[UserFields.name], propName: UserFields.name, defaultValue: defaultName);
      final email = verifyRequiredProp<String>(prop: json[UserFields.email], propName: UserFields.email, defaultValue: defaultEmail);
      final createdAt = verifyRequiredProp<int>(prop: json[UserFields.createdAt], propName: UserFields.createdAt, defaultValue: 0);

      // get properties that are not in the map
      final propsList = [
        UserFields.uid,
        UserFields.name,
        UserFields.email,
        UserFields.createdAt,
      ];

      verifyProps(json, propsList);

      return User(
        uid: uid,
        name: name,
        email: email,
        createdAt: createdAt,
      );
    } catch (e) {
      e.tbLogger('ERROR CONSTRUCTING USER', DebugLevel.error);
      return User.empty();
    }
  }

  FirestorePayload toJson() => {
        UserFields.uid: uid,
        UserFields.name: name,
        UserFields.email: email,
        UserFields.createdAt: createdAt,
      };

  User copyWith({
    String? uid,
    String? name,
    String? email,
    bool? isPremium,
    int? createdAt,
    List<String>? recipeBatchIds,
    String? currentRecipeBatchId,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return '==================== User ==================== \n'
        'uid: $uid, \n'
        'name: $name, \n'
        'email: $email, \n'
        'createdAt: $createdAt \n'
        ')';
  }
}
