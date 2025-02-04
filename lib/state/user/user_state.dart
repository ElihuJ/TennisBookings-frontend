import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../../models/index.dart';

final defaultId = getUuid();
const defaultName = 'Problem loading user';
const defaultEmail = 'email';

@immutable
class User extends MapView<String, dynamic> implements FirestoreModel {
  final String uid;
  final String name;
  final String email;
  final int accountCreationDate;
  final List<String> clubIds;
  final List<DocumentReference<Map<String, dynamic>>> bookings;
  final int dob;
  final Gender gender;
  final int lastLogin;
  final double? utrRating;
  final bool utrVerified;
  final String? homeClubId;
  final String profilePhoto;
  @override
  final List<String> allFields = UserFields.allFields;

  User({
    this.uid = '',
    this.accountCreationDate = 0,
    this.bookings = const [],
    this.clubIds = const [],
    this.dob = 0,
    this.email = '',
    this.gender = Gender.unknown,
    // ignore: avoid_init_to_null
    this.homeClubId = null,
    this.lastLogin = 0,
    this.name = '',
    // ignore: avoid_init_to_null
    this.utrRating = null,
    this.profilePhoto = '',
    this.utrVerified = false,
  }) : super({
          UserFields.uid: uid,
          UserFields.accountCreationDate: accountCreationDate,
          UserFields.bookings: bookings,
          UserFields.clubIds: clubIds,
          UserFields.dob: dob,
          UserFields.email: email,
          UserFields.gender: gender,
          UserFields.homeClubId: homeClubId,
          UserFields.lastLogin: lastLogin,
          UserFields.name: name,
          UserFields.utrRating: utrRating,
          UserFields.utrVerified: utrVerified,
        });

  User.empty() : this();

  factory User.fromJson(FirestoreResponse json) {
    try {
      // * ================================== Required Props ==================================
      final uid = verifyRequiredProp<String>(prop: json[UserFields.uid], propName: UserFields.uid, defaultValue: defaultId);
      final accountCreationDate =
          verifyRequiredProp<int>(prop: json[UserFields.accountCreationDate], propName: UserFields.accountCreationDate, defaultValue: 0);
      final bookingsRaw = verifyRequiredProp<List>(prop: json[UserFields.bookings], propName: UserFields.bookings, defaultValue: []);
      final clubIdRaw = verifyRequiredProp<List>(prop: json[UserFields.clubIds], propName: UserFields.clubIds, defaultValue: []);
      final dob = verifyRequiredProp<int>(prop: json[UserFields.dob], propName: UserFields.dob, defaultValue: 0);
      final email = verifyRequiredProp<String>(prop: json[UserFields.email], propName: UserFields.email, defaultValue: defaultEmail);
      final genderRaw = verifyRequiredProp<String>(prop: json[UserFields.gender], propName: UserFields.gender, defaultValue: Gender.male.name);
      final lastLogin = verifyRequiredProp<int>(prop: json[UserFields.lastLogin], propName: UserFields.lastLogin, defaultValue: 0);
      final name = verifyRequiredProp<String>(prop: json[UserFields.name], propName: UserFields.name, defaultValue: defaultName);
      final utrVerified = verifyRequiredProp<bool>(prop: json[UserFields.utrVerified], propName: UserFields.utrVerified, defaultValue: false);
      final profilePhoto = verifyRequiredProp<String>(prop: json[UserFields.profilePhoto], propName: UserFields.profilePhoto, defaultValue: '');

      // * ================================== Optional Props ==================================
      final homeClubId = verifyNotRequiredProp<String?>(prop: json[UserFields.homeClubId], propName: UserFields.homeClubId);
      final utrRating = verifyNotRequiredProp<double?>(prop: json[UserFields.utrRating], propName: UserFields.utrRating);

      final bookings = List<DocumentReference<Map<String, dynamic>>>.from(bookingsRaw);
      final clubIds = List<String>.from(clubIdRaw);
      final gender = Gender.values.firstWhere(
        (g) => g.name == genderRaw,
        orElse: () => Gender.unknown,
      );

      verifyProps(json, UserFields.allFields);

      return User(
        uid: uid,
        accountCreationDate: accountCreationDate,
        bookings: bookings,
        clubIds: clubIds,
        dob: dob,
        email: email,
        gender: gender,
        homeClubId: homeClubId,
        lastLogin: lastLogin,
        name: name,
        utrRating: utrRating,
        utrVerified: utrVerified,
        profilePhoto: profilePhoto,
      );
    } catch (e) {
      e.tbLogger('ERROR CONSTRUCTING USER', DebugLevel.error);
      return User.empty();
    }
  }

  @override
  FirestorePayload toJson() => {
        UserFields.uid: uid,
        UserFields.accountCreationDate: accountCreationDate,
        UserFields.bookings: bookings,
        UserFields.clubIds: clubIds,
        UserFields.dob: dob,
        UserFields.email: email,
        UserFields.gender: gender.name,
        UserFields.homeClubId: homeClubId,
        UserFields.lastLogin: lastLogin,
        UserFields.name: name,
        UserFields.utrRating: utrRating,
        UserFields.utrVerified: utrVerified,
        UserFields.profilePhoto: profilePhoto,
      };

  @override
  User copyWith({
    String? uid,
    int? accountCreationDate,
    List<DocumentReference<Map<String, dynamic>>>? bookings,
    List<String>? clubIds,
    int? dob,
    String? email,
    Gender? gender,
    String? homeClubId,
    int? lastLogin,
    String? name,
    double? utrRating,
    bool? utrVerified,
    String? profilePhoto,
  }) {
    return User(
      uid: uid ?? this.uid,
      accountCreationDate: accountCreationDate ?? this.accountCreationDate,
      bookings: bookings ?? this.bookings,
      clubIds: clubIds ?? this.clubIds,
      dob: dob ?? this.dob,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      homeClubId: homeClubId ?? this.homeClubId,
      lastLogin: lastLogin ?? this.lastLogin,
      name: name ?? this.name,
      utrRating: utrRating ?? this.utrRating,
      utrVerified: utrVerified ?? this.utrVerified,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }

  @override
  String toString() {
    return '==================== User ==================== \n'
        'uid: $uid \n'
        'accountCreationDate: $accountCreationDate \n'
        'bookings: $bookings \n'
        'clubIds: $clubIds \n'
        'dob: $dob \n'
        'email: $email \n'
        'gender: $gender \n'
        'homeClubId: $homeClubId \n'
        'lastLogin: $lastLogin \n'
        'name: $name \n'
        'utrRating: $utrRating \n'
        'utrVerified: $utrVerified \n'
        'profilePhoto: $profilePhoto \n'
        '=============================================== \n';
  }
}
