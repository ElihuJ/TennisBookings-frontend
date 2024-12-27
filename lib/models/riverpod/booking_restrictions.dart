import 'dart:collection';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../index.dart';

class BookingRestrictions extends MapView<String, dynamic> implements FirestoreModel {
  final bool utrVerified;
  final double utrGt;
  final double utrLt;

  @override
  final List<String> allFields = BookingRestrictionsFields.allFields;

  BookingRestrictions({
    required this.utrVerified,
    required this.utrGt,
    required this.utrLt,
  }) : super({
          BookingRestrictionsFields.utrVerified: utrVerified,
          BookingRestrictionsFields.utrGt: utrGt,
          BookingRestrictionsFields.utrLt: utrLt,
        });

  BookingRestrictions.empty()
      : this(
          utrVerified: false,
          utrGt: 0,
          utrLt: 0,
        );

  @override
  BookingRestrictions copyWith({
    bool? utrVerified,
    double? utrGt,
    double? utrLt,
  }) {
    return BookingRestrictions(
      utrVerified: utrVerified ?? this.utrVerified,
      utrGt: utrGt ?? this.utrGt,
      utrLt: utrLt ?? this.utrLt,
    );
  }

  @override
  FirestorePayload toJson() {
    return {
      BookingRestrictionsFields.utrVerified: utrVerified,
      BookingRestrictionsFields.utrGt: utrGt,
      BookingRestrictionsFields.utrLt: utrLt,
    };
  }

  factory BookingRestrictions.fromJson(Map<String, dynamic> json) {
    try {
      // * Verify required props
      final utrVerified = verifyRequiredProp<bool>(
          prop: json[BookingRestrictionsFields.utrVerified], propName: BookingRestrictionsFields.utrVerified, defaultValue: false);
      final utrGt =
          verifyRequiredProp<double>(prop: json[BookingRestrictionsFields.utrGt], propName: BookingRestrictionsFields.utrGt, defaultValue: 0);
      final utrLt =
          verifyRequiredProp<double>(prop: json[BookingRestrictionsFields.utrLt], propName: BookingRestrictionsFields.utrLt, defaultValue: 0);

      verifyProps(json, BookingRestrictionsFields.allFields);

      return BookingRestrictions(
        utrVerified: utrVerified,
        utrGt: utrGt,
        utrLt: utrLt,
      );
    } catch (e) {
      e.tbLogger('ERROR CONSTRUCTING BOOKING RESTRICTION', DebugLevel.error);
      return BookingRestrictions.empty();
    }
  }
}
