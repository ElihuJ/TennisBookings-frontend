import 'dart:collection';

import 'package:tennisbookings/global_types/index.dart';
import 'package:tennisbookings/models/index.dart';

import '../../global_helpers/index.dart';

class GeneralUnavailability extends MapView<String, dynamic> implements FirestoreModel {
  final DayOfTheWeek dayOfTheWeek;
  final int from;
  final int to;
  @override
  final List<String> allFields = GeneralUnavailabilityFields.allFields;

  GeneralUnavailability({
    required this.dayOfTheWeek,
    required this.from,
    required this.to,
  }) : super({
          GeneralUnavailabilityFields.dayOfTheWeek: dayOfTheWeek,
          GeneralUnavailabilityFields.from: from,
          GeneralUnavailabilityFields.to: to,
        });

  GeneralUnavailability.empty()
      : this(
          dayOfTheWeek: DayOfTheWeek.monday,
          from: 0,
          to: 0,
        );

  @override
  GeneralUnavailability copyWith({
    DayOfTheWeek? dayOfTheWeek,
    int? from,
    int? to,
  }) {
    return GeneralUnavailability(
      dayOfTheWeek: dayOfTheWeek ?? this.dayOfTheWeek,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }

  @override
  FirestorePayload toJson() {
    return {
      GeneralUnavailabilityFields.dayOfTheWeek: dayOfTheWeek.toString(),
      GeneralUnavailabilityFields.from: from,
      GeneralUnavailabilityFields.to: to,
    };
  }

  factory GeneralUnavailability.fromJson(Map<String, dynamic> json) {
    try {
      // * Verify required props

      final from = verifyRequiredProp<int>(prop: json[GeneralUnavailabilityFields.from], propName: GeneralUnavailabilityFields.from, defaultValue: 0);
      final to = verifyRequiredProp<int>(prop: json[GeneralUnavailabilityFields.to], propName: GeneralUnavailabilityFields.to, defaultValue: 0);
      final dayOfTheWeek = DayOfTheWeek.fromString(json[GeneralUnavailabilityFields.dayOfTheWeek]);

      verifyProps(json, GeneralUnavailabilityFields.allFields);

      return GeneralUnavailability(dayOfTheWeek: dayOfTheWeek, from: from, to: to);
    } catch (e) {
      e.tbLogger('ERROR CONSTRUCTING GENERAL UNAVAILABILITY', DebugLevel.error);
      return GeneralUnavailability.empty();
    }
  }
}
