import 'dart:collection';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../index.dart';

final defaultCourtId = getUuid();
final defaultCourtName = 'Problem loading Court';

class Court extends MapView<String, dynamic> implements FirestoreModel, HasId, HasName {
  @override
  final String id;
  final String clubId;
  final String surface;
  @override
  final String name;
  List<Booking>? publicBookings;
  List<Booking>? privateBookings;
  final List<GeneralUnavailability> generalUnavailability;
  @override
  final List<String> allFields = CourtFields.allFields;

  List<String>? get bookingIds => publicBookings?.map((e) => e.id).toList();

  Court({
    required this.id,
    required this.clubId,
    required this.surface,
    this.publicBookings,
    this.privateBookings,
    required this.generalUnavailability,
    required this.name,
  }) : super({
          CourtFields.id: id,
          CourtFields.clubId: clubId,
          CourtFields.surface: surface,
          CourtFields.generalUnavailability: generalUnavailability,
          CourtFields.publicBookings: publicBookings,
          CourtFields.privateBookings: privateBookings,
          CourtFields.name: name,
        });

  Court.empty() : this(id: defaultCourtId, clubId: defaultCourtId, surface: 'unknown', name: defaultCourtName, generalUnavailability: []);

  // ^ ================================== Loaders ==================================

  void loadPublicBookings(List<Booking> publicBookings) {
    this.publicBookings ??= [];
    final bookingIds = this.publicBookings?.map((e) => e.id).toList();
    for (final booking in publicBookings) {
      if (bookingIds != null && !bookingIds.contains(booking.id)) {
        this.publicBookings!.add(booking);
      }
    }
  }

  void loadPrivateBookings(List<Booking> privateBookings) {
    this.privateBookings ??= [];
    final bookingIds = this.privateBookings?.map((e) => e.id).toList();
    for (final booking in privateBookings) {
      if (bookingIds != null && !bookingIds.contains(booking.id)) {
        this.privateBookings!.add(booking);
      }
    }
  }
  // ^ ================================== BoilerPlate ==================================

  factory Court.fromJson(Map<String, dynamic> json) {
    try {
      // * Verify required props
      final id = verifyRequiredProp<String>(prop: json[CourtFields.id], propName: CourtFields.id, defaultValue: defaultCourtId);
      final clubId = verifyRequiredProp<String>(prop: json[CourtFields.clubId], propName: CourtFields.clubId, defaultValue: defaultCourtId);
      final surface = verifyRequiredProp<String>(prop: json[CourtFields.surface], propName: CourtFields.surface, defaultValue: 'unknown');
      final name = verifyRequiredProp<String>(prop: json[CourtFields.name], propName: CourtFields.name, defaultValue: defaultCourtName);
      final List<GeneralUnavailability> generalUnavailability = json[CourtFields.generalUnavailability] != null
          ? List<GeneralUnavailability>.from(json[CourtFields.generalUnavailability].map((x) => GeneralUnavailability.fromJson(x)))
          : [];

      final List<Booking>? bookings =
          json[CourtFields.publicBookings] != null ? List<Booking>.from(json[CourtFields.publicBookings].map((x) => Booking.fromJson(x))) : null;

      List<Booking>? publicBookings;
      List<Booking>? privateBookings;

      if (bookings != null) {
        publicBookings = bookings.where((booking) => booking.private == false).toList();
        privateBookings = bookings.where((booking) => booking.private == true).toList();
      }

      return Court(
        id: id,
        clubId: clubId,
        surface: surface,
        publicBookings: publicBookings,
        generalUnavailability: generalUnavailability,
        name: name,
        privateBookings: privateBookings,
      );
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
    List<Booking>? privateBookings,
    String? name,
  }) {
    return Court(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      surface: surface ?? this.surface,
      publicBookings: publicBookings ?? this.publicBookings,
      generalUnavailability: generalUnavailability ?? this.generalUnavailability,
      privateBookings: privateBookings ?? this.privateBookings,
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
        CourtFields.privateBookings: privateBookings,
        CourtFields.name: name,
      };
}
