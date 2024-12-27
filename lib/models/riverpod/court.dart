import 'dart:collection';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../index.dart';

final defaultCourtId = getUuid();
final defaultCourtName = 'Problem loading Court';

class Court extends MapView<String, dynamic> implements FirestoreModel, HasId {
  @override
  final String id;
  final String clubId;
  final String surface;
  final String name;
  final List<Booking> publicBookings;
  final List<GeneralUnavailability> generalUnavailability;
  @override
  final List<String> allFields = CourtFields.allFields;

  Court({
    required this.id,
    required this.clubId,
    required this.surface,
    required this.publicBookings,
    required this.generalUnavailability,
    required this.name,
  }) : super({
          CourtFields.id: id,
          CourtFields.clubId: clubId,
          CourtFields.surface: surface,
          CourtFields.publicBookings: publicBookings,
          CourtFields.generalUnavailability: generalUnavailability,
          CourtFields.name: name,
        });

  Court.empty()
      : this(id: defaultCourtId, clubId: defaultCourtId, surface: 'Unknown', name: defaultCourtName, generalUnavailability: [], publicBookings: []);

  // ^ ================================== Loaders ==================================

  void loadBookings(List<Booking> publicBookings) {
    for (final publicBooking in publicBookings) {
      if (this.publicBookings.contains(publicBooking)) {
        continue;
      }
      this.publicBookings.add(publicBooking);
    }
  }

  // ^ ================================== BoilerPlate ==================================

  factory Court.fromJson(Map<String, dynamic> json) {
    try {
      // * Verify required props
      final id = verifyRequiredProp<String>(prop: json[CourtFields.id], propName: CourtFields.id, defaultValue: defaultCourtId);
      final clubId = verifyRequiredProp<String>(prop: json[CourtFields.clubId], propName: CourtFields.clubId, defaultValue: defaultCourtId);
      final surface = verifyRequiredProp<String>(prop: json[CourtFields.surface], propName: CourtFields.surface, defaultValue: 'Unknown');
      final name = verifyRequiredProp<String>(prop: json[CourtFields.name], propName: CourtFields.name, defaultValue: defaultCourtName);
      final List<GeneralUnavailability> generalUnavailability = json[CourtFields.generalUnavailability] != null
          ? List<GeneralUnavailability>.from(json[CourtFields.generalUnavailability].map((x) => GeneralUnavailability.fromJson(x)))
          : [];

      final List<Booking> publicBookings =
          json[CourtFields.publicBookings] != null ? List<Booking>.from(json[CourtFields.publicBookings].map((x) => Booking.fromJson(x))) : [];

      verifyProps(json, CourtFields.allFields);

      return Court(
          id: id, clubId: clubId, surface: surface, publicBookings: publicBookings, generalUnavailability: generalUnavailability, name: name);
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
    List<Booking>? publicBookings,
    List<GeneralUnavailability>? generalUnavailability,
    String? name,
  }) {
    return Court(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      surface: surface ?? this.surface,
      publicBookings: publicBookings ?? this.publicBookings,
      generalUnavailability: generalUnavailability ?? this.generalUnavailability,
      name: name ?? this.name,
    );
  }

  @override
  FirestorePayload toJson() => {
        CourtFields.id: id,
        CourtFields.clubId: clubId,
        CourtFields.surface: surface,
        CourtFields.publicBookings: publicBookings,
        CourtFields.generalUnavailability: generalUnavailability,
        CourtFields.name: name,
      };
}
