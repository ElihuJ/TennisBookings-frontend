import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../global_helpers/index.dart';
import '../../models/index.dart';

final defaultClubId = getUuid();
const defaultClubName = 'Problem loading Club';

@immutable
class Club extends MapView<String, dynamic> implements HasId {
  @override
  final String id;
  final String name;
  final List<String> adminIds;
  final int hardCourts;
  final int clayCourts;
  final int grassCourts;
  final int otherSurfaceCourts;
  final double annualFee;
  final double? casualFee;
  final bool onlyMembers;
  final String streetAddress;
  final String suburb;
  final String city;
  final int postcode;
  final String state;
  final List<Court> courts;
  final String clubLogoUrl;
  final String? contactEmail;
  final String? contactPhone;
  final List<String> memberIds;
  final Currency currency;

  Club({
    required this.id,
    required this.name,
    required this.adminIds,
    required this.hardCourts,
    required this.clayCourts,
    required this.grassCourts,
    required this.otherSurfaceCourts,
    required this.annualFee,
    required this.onlyMembers,
    required this.streetAddress,
    required this.suburb,
    required this.city,
    required this.postcode,
    required this.state,
    required this.courts,
    required this.clubLogoUrl,
    required this.memberIds,
    required this.currency,
    this.casualFee,
    this.contactEmail,
    this.contactPhone,
  }) : super({
          ClubFields.id: id,
          ClubFields.name: name,
          ClubFields.adminIds: adminIds,
          ClubFields.hardCourts: hardCourts,
          ClubFields.clayCourts: clayCourts,
          ClubFields.grassCourts: grassCourts,
          ClubFields.otherSurfaceCourts: otherSurfaceCourts,
          ClubFields.annualFee: annualFee,
          ClubFields.casualFee: casualFee,
          ClubFields.onlyMembers: onlyMembers,
          ClubFields.streetAddress: streetAddress,
          ClubFields.suburb: suburb,
          ClubFields.city: city,
          ClubFields.postcode: postcode,
          ClubFields.state: state,
          ClubFields.courts: courts,
          ClubFields.clubLogoUrl: clubLogoUrl,
          ClubFields.memberIds: memberIds,
          ClubFields.currency: currency,
        });

  Club.empty()
      : this(
          id: defaultClubId,
          name: defaultClubName,
          adminIds: [],
          hardCourts: 0,
          clayCourts: 0,
          grassCourts: 0,
          otherSurfaceCourts: 0,
          annualFee: 0.0,
          casualFee: null,
          onlyMembers: false,
          streetAddress: '',
          suburb: '',
          city: '',
          postcode: 0,
          state: '',
          courts: [],
          clubLogoUrl: '',
          contactEmail: null,
          contactPhone: null,
          memberIds: [],
          currency: Currency.aud,
        );

  // ^ ================================== Loaders ==================================

  void loadCourtsFromDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final List<Court> courts = docs.map((doc) => Court.fromJson(doc.data())).toList();
    for (final court in courts) {
      bool exist = false;
      for (final loadedCourt in this.courts) {
        // * Checking if ID already exist in state
        if (loadedCourt.id == court.id) {
          exist = true;
          break;
        }
      }
      if (!exist) {
        this.courts.add(court);
      }
    }
  }

  // ^ ================================== BoilerPlate ==================================

  factory Club.fromJson(Map<String, dynamic> json) {
    // * ================================== Required Props ==================================
    final id = verifyRequiredProp<String>(prop: json[ClubFields.id], propName: ClubFields.id, defaultValue: defaultClubId);
    final name = verifyRequiredProp<String>(prop: json[ClubFields.name], propName: ClubFields.name, defaultValue: defaultClubName);
    final adminIdsRaw = verifyRequiredProp<List>(prop: json[ClubFields.adminIds], propName: ClubFields.adminIds, defaultValue: []);
    final hardCourts = verifyRequiredProp<int>(prop: json[ClubFields.hardCourts], propName: ClubFields.hardCourts, defaultValue: 0);
    final clayCourts = verifyRequiredProp<int>(prop: json[ClubFields.clayCourts], propName: ClubFields.clayCourts, defaultValue: 0);
    final grassCourts = verifyRequiredProp<int>(prop: json[ClubFields.grassCourts], propName: ClubFields.grassCourts, defaultValue: 0);
    final otherSurfaceCourts =
        verifyRequiredProp<int>(prop: json[ClubFields.otherSurfaceCourts], propName: ClubFields.otherSurfaceCourts, defaultValue: 0);
    final annualFee = verifyRequiredProp<double>(prop: json[ClubFields.annualFee], propName: ClubFields.annualFee, defaultValue: 0.0);
    final onlyMembers = verifyRequiredProp<bool>(prop: json[ClubFields.onlyMembers], propName: ClubFields.onlyMembers, defaultValue: true);
    final streetAddress = verifyRequiredProp<String>(prop: json[ClubFields.streetAddress], propName: ClubFields.streetAddress, defaultValue: '');
    final suburb = verifyRequiredProp<String>(prop: json[ClubFields.suburb], propName: ClubFields.suburb, defaultValue: '');
    final city = verifyRequiredProp<String>(prop: json[ClubFields.city], propName: ClubFields.city, defaultValue: '');
    final postcode = verifyRequiredProp<int>(prop: json[ClubFields.postcode], propName: ClubFields.postcode, defaultValue: 0);
    final state = verifyRequiredProp<String>(prop: json[ClubFields.state], propName: ClubFields.state, defaultValue: '');
    final clubLogoUrl = verifyRequiredProp<String>(prop: json[ClubFields.clubLogoUrl], propName: ClubFields.clubLogoUrl, defaultValue: '');
    final memberIdsRaw = verifyRequiredProp<List>(prop: json[ClubFields.memberIds], propName: ClubFields.memberIds, defaultValue: []);
    final currencyRaw = verifyRequiredProp<String>(prop: json[ClubFields.currency], propName: ClubFields.currency, defaultValue: Currency.aud.value);
    // * ================================== Verify not required props ==================================
    final casualFee = verifyNotRequiredProp<double>(prop: json[ClubFields.casualFee], propName: ClubFields.casualFee);
    final contactEmail = verifyNotRequiredProp<String>(prop: json[ClubFields.contactEmail], propName: ClubFields.contactEmail);
    final contactPhone = verifyNotRequiredProp<String>(prop: json[ClubFields.contactPhone], propName: ClubFields.contactPhone);

    // * ================================== Courts to List ==================================
    List<Court> courts = json[ClubFields.courts] != null ? List<Court>.from(json[ClubFields.courts].map((x) => Court.fromJson(x))) : [];
    final adminIds = List<String>.from(adminIdsRaw);
    final memberIds = List<String>.from(memberIdsRaw);

    final currency = Currency.values.firstWhere((e) => e.value == currencyRaw, orElse: () => Currency.aud);

    verifyProps(json, ClubFields.allFields);

    return Club(
      id: id,
      name: name,
      adminIds: adminIds,
      hardCourts: hardCourts,
      clayCourts: clayCourts,
      grassCourts: grassCourts,
      otherSurfaceCourts: otherSurfaceCourts,
      annualFee: annualFee,
      casualFee: casualFee ?? 0.0,
      onlyMembers: onlyMembers,
      streetAddress: streetAddress,
      suburb: suburb,
      city: city,
      postcode: postcode,
      state: state,
      courts: courts,
      clubLogoUrl: clubLogoUrl,
      contactEmail: contactEmail,
      currency: currency,
      contactPhone: contactPhone,
      memberIds: memberIds,
    );
  }

  Club copyWith({
    String? id,
    String? name,
    List<String>? adminIds,
    int? hardCourts,
    int? clayCourts,
    int? grassCourts,
    int? otherSurfaceCourts,
    double? annualFee,
    double? casualFee,
    bool? onlyMembers,
    String? streetAddress,
    String? suburb,
    String? city,
    int? postcode,
    String? state,
    List<Court>? courts,
    List<String>? memberIds,
    String? clubLogoUrl,
    String? contactEmail,
    String? contactPhone,
    Currency? currency,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      adminIds: adminIds ?? this.adminIds,
      hardCourts: hardCourts ?? this.hardCourts,
      clayCourts: clayCourts ?? this.clayCourts,
      grassCourts: grassCourts ?? this.grassCourts,
      otherSurfaceCourts: otherSurfaceCourts ?? this.otherSurfaceCourts,
      annualFee: annualFee ?? this.annualFee,
      casualFee: casualFee ?? this.casualFee,
      onlyMembers: onlyMembers ?? this.onlyMembers,
      streetAddress: streetAddress ?? this.streetAddress,
      suburb: suburb ?? this.suburb,
      city: city ?? this.city,
      postcode: postcode ?? this.postcode,
      state: state ?? this.state,
      courts: courts ?? this.courts,
      clubLogoUrl: clubLogoUrl ?? this.clubLogoUrl,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      memberIds: memberIds ?? this.memberIds,
      currency: currency ?? this.currency,
    );
  }

  @override
  String toString() {
    return '==================== $name ==================== \n'
        'id: $id, \n'
        'adminIds: $adminIds, \n'
        'hardCourts: $hardCourts, \n'
        'clayCourts: $clayCourts, \n'
        'grassCourts: $grassCourts, \n'
        'otherSurfaceCourts: $otherSurfaceCourts, \n'
        'annualFee: $annualFee, \n'
        'casualFee: $casualFee, \n'
        'onlyMembers: $onlyMembers, \n'
        'streetAddress: $streetAddress, \n'
        'suburb: $suburb, \n'
        'city: $city, \n'
        'postcode: $postcode, \n'
        'state: $state, \n'
        'courts: $courts, \n'
        'clubLogoUrl: $clubLogoUrl, \n'
        'contactEmail: $contactEmail, \n'
        'contactPhone: $contactPhone, \n'
        'memberIds: $memberIds, \n'
        'currency: $currency, \n'
        '=============================================== \n';
  }
}

enum Currency {
  aud('aud'),
  usd('usd'),
  mxn('mxn');

  final String value;

  const Currency(this.value);

  @override
  String toString() => value;
}
