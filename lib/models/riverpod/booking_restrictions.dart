import 'dart:collection';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../index.dart';

class BookingRestrictions extends MapView<String, dynamic> implements FirestoreModel {
  final bool utrVerified;
  final double? utrGt;
  final double? utrLt;
  final Gender? gender;

  @override
  final List<String> allFields = BookingRestrictionsFields.allFields;

  BookingRestrictions({
    required this.utrVerified,
    this.utrGt,
    this.utrLt,
    this.gender,
  }) : super({
          BookingRestrictionsFields.utrVerified: utrVerified,
          BookingRestrictionsFields.utrGt: utrGt,
          BookingRestrictionsFields.utrLt: utrLt,
          BookingRestrictionsFields.gender: gender,
        });

  BookingRestrictions.empty()
      : this(
          utrVerified: false,
          utrGt: null,
          utrLt: null,
          gender: null,
        );

  @override
  BookingRestrictions copyWith({
    bool? utrVerified,
    double? utrGt,
    double? utrLt,
    Gender? gender,
  }) {
    return BookingRestrictions(
      utrVerified: utrVerified ?? this.utrVerified,
      utrGt: utrGt ?? this.utrGt,
      utrLt: utrLt ?? this.utrLt,
      gender: gender ?? this.gender,
    );
  }

  @override
  FirestorePayload toJson() {
    return {
      BookingRestrictionsFields.utrVerified: utrVerified,
      BookingRestrictionsFields.utrGt: utrGt,
      BookingRestrictionsFields.utrLt: utrLt,
      BookingRestrictionsFields.gender: gender?.name,
    };
  }

  factory BookingRestrictions.fromJson(Map<String, dynamic> json) {
    try {
      // * Verify required props
      final utrVerified = verifyRequiredProp<bool>(
          prop: json[BookingRestrictionsFields.utrVerified], propName: BookingRestrictionsFields.utrVerified, defaultValue: false);
      final utrGt = verifyNotRequiredProp<double>(prop: json[BookingRestrictionsFields.utrGt], propName: BookingRestrictionsFields.utrGt);
      final utrLt = verifyNotRequiredProp<double>(prop: json[BookingRestrictionsFields.utrLt], propName: BookingRestrictionsFields.utrLt);
      final genderRaw = verifyNotRequiredProp<String?>(prop: json[BookingRestrictionsFields.gender], propName: BookingRestrictionsFields.gender);

      final gender = Gender.values.firstWhere(
        (g) => g.name == genderRaw,
        orElse: () => Gender.unknown,
      );

      verifyProps(json, BookingRestrictionsFields.allFields);

      return BookingRestrictions(
        utrVerified: utrVerified,
        utrGt: utrGt,
        utrLt: utrLt,
        gender: gender,
      );
    } catch (e) {
      e.tbLogger('ERROR CONSTRUCTING BOOKING RESTRICTION', DebugLevel.error);
      return BookingRestrictions.empty();
    }
  }
}
