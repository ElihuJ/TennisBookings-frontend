import 'dart:collection';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../index.dart';

class GeneralUnavailability extends MapView<String, dynamic> implements FirestoreModel {
  final DayOfTheWeek dayOfTheWeek;
  final int startTime;
  final int endTime;
  @override
  final List<String> allFields = GeneralUnavailabilityFields.allFields;

  GeneralUnavailability({
    required this.dayOfTheWeek,
    required this.startTime,
    required this.endTime,
  }) : super({
          GeneralUnavailabilityFields.dayOfTheWeek: dayOfTheWeek,
          GeneralUnavailabilityFields.startTime: startTime,
          GeneralUnavailabilityFields.endTime: endTime,
        });

  GeneralUnavailability.empty()
      : this(
          dayOfTheWeek: DayOfTheWeek.monday,
          startTime: 0,
          endTime: 0,
        );

  @override
  GeneralUnavailability copyWith({
    DayOfTheWeek? dayOfTheWeek,
    int? startTime,
    int? endTime,
  }) {
    return GeneralUnavailability(
      dayOfTheWeek: dayOfTheWeek ?? this.dayOfTheWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  FirestorePayload toJson() {
    return {
      GeneralUnavailabilityFields.dayOfTheWeek: dayOfTheWeek.toString(),
      GeneralUnavailabilityFields.startTime: startTime,
      GeneralUnavailabilityFields.endTime: endTime,
    };
  }

  factory GeneralUnavailability.fromJson(Map<String, dynamic> json) {
    try {
      // * Verify required props

      final startTime = verifyRequiredProp<int>(
          prop: json[GeneralUnavailabilityFields.startTime], propName: GeneralUnavailabilityFields.startTime, defaultValue: 0);
      final endTime =
          verifyRequiredProp<int>(prop: json[GeneralUnavailabilityFields.endTime], propName: GeneralUnavailabilityFields.endTime, defaultValue: 0);
      final dayOfTheWeek = DayOfTheWeek.fromString(json[GeneralUnavailabilityFields.dayOfTheWeek]);

      verifyProps(json, GeneralUnavailabilityFields.allFields);

      return GeneralUnavailability(dayOfTheWeek: dayOfTheWeek, startTime: startTime, endTime: endTime);
    } catch (e) {
      e.tbLogger('ERROR CONSTRUCTING GENERAL UNAVAILABILITY', DebugLevel.error);
      return GeneralUnavailability.empty();
    }
  }
}
