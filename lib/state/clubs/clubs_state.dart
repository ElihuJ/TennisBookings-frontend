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
  final bool allowPublicBookings;
  final List<String> memberIds;

  Club({
    required this.id,
    required this.name,
    required this.adminIds,
    required this.hardCourts,
    required this.clayCourts,
    required this.grassCourts,
    required this.otherSurfaceCourts,
    required this.annualFee,
    this.casualFee,
    required this.onlyMembers,
    required this.streetAddress,
    required this.suburb,
    required this.city,
    required this.postcode,
    required this.state,
    required this.courts,
    required this.allowPublicBookings,
    required this.memberIds,
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
          ClubFields.courts: courts
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
          casualFee: 0.0,
          onlyMembers: false,
          streetAddress: '',
          suburb: '',
          city: '',
          postcode: 0,
          state: '',
          courts: [],
          allowPublicBookings: false,
          memberIds: [],
        );

  // ^ ================================== Loaders ==================================

  void loadCourtsFromDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final List<Court> courts = docs.map((doc) => Court.fromJson(doc.data())).toList();
    for (final court in courts) {
      if (!this.courts.contains(court)) {
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
    final onlyMembers = verifyRequiredProp<bool>(prop: json[ClubFields.onlyMembers], propName: ClubFields.onlyMembers, defaultValue: false);
    final streetAddress = verifyRequiredProp<String>(prop: json[ClubFields.streetAddress], propName: ClubFields.streetAddress, defaultValue: '');
    final suburb = verifyRequiredProp<String>(prop: json[ClubFields.suburb], propName: ClubFields.suburb, defaultValue: '');
    final city = verifyRequiredProp<String>(prop: json[ClubFields.city], propName: ClubFields.city, defaultValue: '');
    final postcode = verifyRequiredProp<int>(prop: json[ClubFields.postcode], propName: ClubFields.postcode, defaultValue: 0);
    final state = verifyRequiredProp<String>(prop: json[ClubFields.state], propName: ClubFields.state, defaultValue: '');
    final allowPublicBookings =
        verifyRequiredProp<bool>(prop: json[ClubFields.allowPublicBookings], propName: ClubFields.allowPublicBookings, defaultValue: false);
    final memberIds = verifyRequiredProp<List>(prop: json[ClubFields.memberIds], propName: ClubFields.memberIds, defaultValue: []);

    // * ================================== Verify not required props ==================================
    final casualFee = verifyNotRequiredProp<double>(prop: json[ClubFields.casualFee], propName: ClubFields.casualFee);

    // * ================================== Courts to List ==================================
    List<Court> courts = json[ClubFields.courts] != null ? List<Court>.from(json[ClubFields.courts].map((x) => Court.fromJson(x))) : [];

    verifyProps(json, ClubFields.allFields);

    return Club(
      id: id,
      name: name,
      adminIds: List<String>.from(adminIdsRaw),
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
      allowPublicBookings: allowPublicBookings,
      memberIds: List<String>.from(memberIds),
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
    bool? allowPublicBookings,
    List<String>? memberIds,
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
      allowPublicBookings: allowPublicBookings ?? this.allowPublicBookings,
      memberIds: memberIds ?? this.memberIds,
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
        'allowPublicBookings: $allowPublicBookings, \n'
        'memberIds: $memberIds, \n'
        '=============================================== \n';
  }
}
