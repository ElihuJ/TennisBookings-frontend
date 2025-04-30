import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../../models/index.dart';
import './index.dart';

final _defaultId = getUuid();
const _defaultName = 'Problem loading user';
const _defaultEmail = 'email';

@immutable
class User extends MapView<String, dynamic> implements FirestoreModel {
  final String uid;
  final String name;
  final String email;
  final int accountCreationDate;
  final List<DocumentReference<Map<String, dynamic>>> bookings;
  final int dob; // date of birth in epoch milliseconds
  final Gender gender;
  final int lastLogin;
  final bool utrVerified;
  final String photoUrl;
  final List<UserMembership> memberships;
  final String? homeClubId;
  final double? utrRating;
  @override
  final List<String> allFields = UserFields.allFields;

  User({
    required this.uid,
    required this.accountCreationDate,
    required this.bookings,
    required this.dob,
    required this.email,
    required this.gender,
    required this.lastLogin,
    required this.name,
    required this.photoUrl,
    required this.utrVerified,
    required this.memberships,
    this.utrRating,
    this.homeClubId,
  }) : super({
          UserFields.uid: uid,
          UserFields.accountCreationDate: accountCreationDate,
          UserFields.bookings: bookings,
          UserFields.dob: dob,
          UserFields.email: email,
          UserFields.gender: gender,
          UserFields.homeClubId: homeClubId,
          UserFields.lastLogin: lastLogin,
          UserFields.name: name,
          UserFields.utrRating: utrRating,
          UserFields.utrVerified: utrVerified,
          UserFields.photoUrl: photoUrl,
        });

  User.empty()
      : this(
          uid: '',
          accountCreationDate: 0,
          memberships: [],
          gender: Gender.unknown,
          lastLogin: 0,
          name: _defaultName,
          photoUrl: '',
          utrVerified: false,
          bookings: [],
          dob: 0,
          email: _defaultEmail,
        );

  factory User.fromJson(FirestoreResponse json) {
    try {
      // * ================================== Required Props ==================================
      final uid = verifyRequiredProp<String>(prop: json[UserFields.uid], propName: UserFields.uid, defaultValue: _defaultId);
      final accountCreationDate =
          verifyRequiredProp<int>(prop: json[UserFields.accountCreationDate], propName: UserFields.accountCreationDate, defaultValue: 0);
      final bookingsRaw = verifyRequiredProp<List>(prop: json[UserFields.bookings], propName: UserFields.bookings, defaultValue: []);
      final dob = verifyRequiredProp<int>(prop: json[UserFields.dob], propName: UserFields.dob, defaultValue: 0);
      final email = verifyRequiredProp<String>(prop: json[UserFields.email], propName: UserFields.email, defaultValue: _defaultEmail);
      final genderRaw = verifyRequiredProp<String>(prop: json[UserFields.gender], propName: UserFields.gender, defaultValue: Gender.unknown.name);
      final lastLogin = verifyRequiredProp<int>(prop: json[UserFields.lastLogin], propName: UserFields.lastLogin, defaultValue: 0);
      final name = verifyRequiredProp<String>(prop: json[UserFields.name], propName: UserFields.name, defaultValue: _defaultName);
      final utrVerified = verifyRequiredProp<bool>(prop: json[UserFields.utrVerified], propName: UserFields.utrVerified, defaultValue: false);
      final photoUrl = verifyRequiredProp<String>(prop: json[UserFields.photoUrl], propName: UserFields.photoUrl, defaultValue: '');
      final membershipsRaw = verifyRequiredProp<List>(prop: json[UserFields.memberships], propName: UserFields.memberships, defaultValue: []);

      // * ================================== Optional Props ==================================
      final homeClubId = verifyNotRequiredProp<String?>(prop: json[UserFields.homeClubId], propName: UserFields.homeClubId);
      final utrRating = verifyNotRequiredProp<double?>(prop: json[UserFields.utrRating], propName: UserFields.utrRating);

      // * Transformations
      List<DocumentReference<Map<String, dynamic>>> bookings;
      try {
        bookings = List<DocumentReference<Map<String, dynamic>>>.from(bookingsRaw);
      } catch (e) {
        e.tbLogger('ERROR CONVERTING BOOKINGS', DebugLevel.warning);
        bookings = [];
      }
      final gender = Gender.values.firstWhere(
        (g) => g.name == genderRaw,
        orElse: () => Gender.unknown,
      );
      final memberships = List<UserMembership>.from(membershipsRaw.map((x) => UserMembership.fromJson(x)));

      verifyProps(json, UserFields.allFields);

      return User(
        uid: uid,
        accountCreationDate: accountCreationDate,
        bookings: bookings,
        dob: dob,
        email: email,
        gender: gender,
        homeClubId: homeClubId,
        lastLogin: lastLogin,
        name: name,
        utrRating: utrRating,
        utrVerified: utrVerified,
        photoUrl: photoUrl,
        memberships: memberships,
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
        UserFields.dob: dob,
        UserFields.email: email,
        UserFields.gender: gender.name,
        UserFields.homeClubId: homeClubId,
        UserFields.lastLogin: lastLogin,
        UserFields.name: name,
        UserFields.utrRating: utrRating,
        UserFields.utrVerified: utrVerified,
        UserFields.photoUrl: photoUrl,
        UserFields.memberships: memberships.map((e) => e.toJson()).toList(),
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
    String? photoUrl,
    List<UserMembership>? memberships,
  }) {
    return User(
      uid: uid ?? this.uid,
      accountCreationDate: accountCreationDate ?? this.accountCreationDate,
      bookings: bookings ?? this.bookings,
      dob: dob ?? this.dob,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      homeClubId: homeClubId ?? this.homeClubId,
      lastLogin: lastLogin ?? this.lastLogin,
      name: name ?? this.name,
      utrRating: utrRating ?? this.utrRating,
      utrVerified: utrVerified ?? this.utrVerified,
      photoUrl: photoUrl ?? this.photoUrl,
      memberships: memberships ?? this.memberships,
    );
  }

  @override
  String toString() {
    return '==================== User ==================== \n'
        'uid: $uid \n'
        'accountCreationDate: $accountCreationDate \n'
        'bookings: $bookings \n'
        'dob: $dob \n'
        'email: $email \n'
        'gender: $gender \n'
        'homeClubId: $homeClubId \n'
        'lastLogin: $lastLogin \n'
        'name: $name \n'
        'utrRating: $utrRating \n'
        'utrVerified: $utrVerified \n'
        'photoUrl: $photoUrl \n'
        'memberships: $memberships \n'
        '=============================================== \n';
  }
}
