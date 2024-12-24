import 'dart:collection';

import 'package:tennisbookings/global_helpers/index.dart';
import 'package:tennisbookings/models/riverpod/general_unavailability.dart';

import '../../global_types/index.dart';
import '../index.dart';

final defaultId = getUuid();
final defaultName = 'Problem loading Court';

class Court extends MapView<String, dynamic> implements FirestoreModel {
  final String id;
  final String clubId;
  final String surface;
  final String name;
  // final SubCollection bookings;
  final List<GeneralUnavailability> generalUnavailability;
  @override
  final List<String> allFields = CourtFields.allFields;

  Court({
    required this.id,
    required this.clubId,
    required this.surface,
    // required this.bookings, // TODO: Implement bookings
    required this.generalUnavailability,
    required this.name,
  }) : super({
          CourtFields.id: id,
          CourtFields.clubId: clubId,
          CourtFields.surface: surface,
          // CourtFields.bookings: bookings,
          CourtFields.generalUnavailability: generalUnavailability,
          CourtFields.name: name,
        });

  Court.empty() : this(id: defaultId, clubId: defaultId, surface: 'Unknown', name: defaultName, generalUnavailability: []);

  factory Court.fromJson(Map<String, dynamic> json) {
    try {
      json.tbLogger('Court.fromJson');

      // * Verify required props
      final id = verifyRequiredProp<String>(prop: json[CourtFields.id], propName: CourtFields.id, defaultValue: defaultId);
      final clubId = verifyRequiredProp<String>(prop: json[CourtFields.clubId], propName: CourtFields.clubId, defaultValue: defaultId);
      final surface = verifyRequiredProp<String>(prop: json[CourtFields.surface], propName: CourtFields.surface, defaultValue: 'Unknown');
      final name = verifyRequiredProp<String>(prop: json[CourtFields.name], propName: CourtFields.name, defaultValue: defaultName);
      // final bookings = verifyRequiredProp<SubCollection>(prop: json[CourtFields.bookings], propName: CourtFields.bookings, defaultValue: SubCollection.empty());
      List<GeneralUnavailability> generalUnavailability = json[CourtFields.generalUnavailability] != null
          ? List<GeneralUnavailability>.from(json[CourtFields.generalUnavailability].map((x) => GeneralUnavailability.fromJson(x)))
          : [];

      verifyProps(json, ClubFields.allFields);

      return Court(
          id: id,
          clubId: clubId,
          surface: surface,
          // bookings: bookings,
          generalUnavailability: generalUnavailability,
          name: name);
    } catch (e) {
      e.tbLogger('ERROR CONSTRUCTING COURT', DebugLevel.error);
      return Court.empty();
    }
  }

  @override
  Court copyWith({
    String? id,
    String? clubId,
    String? surface,
    // SubCollection? bookings,
    List<GeneralUnavailability>? generalUnavailability,
    String? name,
  }) {
    return Court(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      surface: surface ?? this.surface,
      // bookings: bookings ?? this.bookings,
      generalUnavailability: generalUnavailability ?? this.generalUnavailability,
      name: name ?? this.name,
    );
  }

  @override
  FirestorePayload toJson() => {
        CourtFields.id: id,
        CourtFields.clubId: clubId,
        CourtFields.surface: surface,
        // CourtFields.bookings: bookings,
        CourtFields.generalUnavailability: generalUnavailability,
        CourtFields.name: name,
      };
}
