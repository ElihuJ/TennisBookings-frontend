import 'dart:collection';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../index.dart';

final _defaultId = getUuid();
final _defaultName = 'Problem loading Booking';
final _defaultClubName = 'Problem loading Club Name';
final _defaultCourtName = 'Problem loading Court Name';

class Booking extends MapView<String, dynamic> implements FirestoreModel, HasId {
  @override
  final String id;
  final List<String> confirmedPlayerIds;
  final String courtId;
  final String clubId;
  final BookingFormat format;
  final int startTime;
  final int endTime;
  final bool private;
  final String ownerId;
  final List<BookingRequest> requests;
  final BookingRestrictions? restrictions;
  final String clubName;
  final String courtName;
  final BookingStatus status;
  final String title;
  final String? clubPin; // * Only existing in private bookings objects
  final String? courtPin; // * Only existing in private bookings objects
  final List<Booking> mergedBookings; // * Used for calendar view ONLY FRONTEND. No DB

  @override
  final List<String> allFields = BookingFields.allFields;

  Booking({
    required this.id,
    required this.confirmedPlayerIds,
    required this.courtId,
    required this.clubId,
    required this.format,
    required this.startTime,
    required this.endTime,
    required this.private,
    required this.ownerId,
    required this.requests,
    this.restrictions,
    required this.status,
    required this.clubName,
    required this.courtName,
    required this.title,
    this.clubPin,
    this.courtPin,
    this.mergedBookings = const [],
  }) : super({
          BookingFields.id: id,
          BookingFields.confirmedPlayerIds: confirmedPlayerIds,
          BookingFields.courtId: courtId,
          BookingFields.clubId: clubId,
          BookingFields.format: format,
          BookingFields.startTime: startTime,
          BookingFields.endTime: endTime,
          BookingFields.private: private,
          BookingFields.ownerId: ownerId,
          BookingFields.requests: requests,
          BookingFields.restrictions: restrictions,
          BookingFields.status: status,
          BookingFields.title: title,
          BookingFields.clubName: clubName,
          BookingFields.courtName: courtName,
          BookingFields.clubPin: clubPin,
          BookingFields.courtPin: courtPin,
        });

  Booking.empty()
      : this(
          id: _defaultId,
          confirmedPlayerIds: [],
          courtId: _defaultId,
          clubId: _defaultId,
          format: BookingFormat.singles,
          startTime: 0,
          endTime: 0,
          private: false,
          ownerId: _defaultId,
          requests: [],
          restrictions: null,
          status: BookingStatus.open,
          title: _defaultName,
          clubName: _defaultClubName,
          courtName: _defaultCourtName,
        );

  factory Booking.fromJson(Map<String, dynamic> json) {
    try {
      // * Verify required props
      final id = verifyRequiredProp<String>(prop: json[BookingFields.id], propName: BookingFields.id, defaultValue: _defaultId);
      final confirmedPlayerIdsRaw = verifyRequiredProp<List>(
          prop: json[BookingFields.confirmedPlayerIds], propName: BookingFields.confirmedPlayerIds, defaultValue: []);
      final courtId =
          verifyRequiredProp<String>(prop: json[BookingFields.courtId], propName: BookingFields.courtId, defaultValue: _defaultId);
      final clubId = verifyRequiredProp<String>(prop: json[BookingFields.clubId], propName: BookingFields.clubId, defaultValue: _defaultId);
      final startTime = verifyRequiredProp<int>(prop: json[BookingFields.startTime], propName: BookingFields.startTime, defaultValue: 0);
      final endTime = verifyRequiredProp<int>(prop: json[BookingFields.endTime], propName: BookingFields.endTime, defaultValue: 0);
      final private = verifyRequiredProp<bool>(prop: json[BookingFields.private], propName: BookingFields.private, defaultValue: false);
      final ownerId =
          verifyRequiredProp<String>(prop: json[BookingFields.ownerId], propName: BookingFields.ownerId, defaultValue: _defaultId);
      final title = verifyRequiredProp<String>(prop: json[BookingFields.title], propName: BookingFields.title, defaultValue: _defaultName);
      final clubName =
          verifyRequiredProp<String>(prop: json[BookingFields.clubName], propName: BookingFields.clubName, defaultValue: _defaultClubName);
      final courtName = verifyRequiredProp<String>(
          prop: json[BookingFields.courtName], propName: BookingFields.courtName, defaultValue: _defaultCourtName);

      // * Optional props
      final courtPin = verifyNotRequiredProp<String?>(prop: json[BookingFields.courtPin], propName: BookingFields.courtPin);
      final clubPin = verifyNotRequiredProp<String?>(prop: json[BookingFields.clubPin], propName: BookingFields.clubPin);

      final List<BookingRequest> requests = json[BookingFields.requests] != null
          ? List<BookingRequest>.from(json[BookingFields.requests].map((x) => BookingRequest.fromJson(x)))
          : [];
      final BookingRestrictions? restrictions =
          json[BookingFields.restrictions] != null ? BookingRestrictions.fromJson(json[BookingFields.restrictions]) : null;
      final status = json[BookingFields.status] != null ? BookingStatus.fromString(json[BookingFields.status]) : BookingStatus.unknown;
      final format = json[BookingFields.format] != null ? BookingFormat.fromString(json[BookingFields.format]) : BookingFormat.unknown;

      final List<String> confirmedPlayerIds = List<String>.from(confirmedPlayerIdsRaw);

      verifyProps(json, BookingFields.allFields);

      return Booking(
        id: id,
        confirmedPlayerIds: confirmedPlayerIds,
        courtId: courtId,
        clubId: clubId,
        format: format,
        startTime: startTime,
        endTime: endTime,
        private: private,
        ownerId: ownerId,
        requests: requests,
        restrictions: restrictions,
        status: status,
        title: title,
        clubName: clubName,
        courtName: courtName,
        clubPin: clubPin,
        courtPin: courtPin,
      );
    } catch (e) {
      e.tbLogger('ERROR CONSTRUCTING BOOKING', DebugLevel.error);
      return Booking.empty();
    }
  }

  void addBookingToMerged(Booking booking) {
    mergedBookings.add(booking);
  }

  @override
  Booking copyWith({
    String? id,
    List<String>? confirmedPlayerIds,
    String? courtId,
    String? clubId,
    BookingFormat? format,
    int? startTime,
    int? endTime,
    bool? private,
    String? ownerId,
    List<BookingRequest>? requests,
    BookingRestrictions? restrictions,
    BookingStatus? status,
    String? title,
    String? clubName,
    String? courtName,
    String? clubPin,
    String? courtPin,
  }) {
    return Booking(
      id: id ?? this.id,
      confirmedPlayerIds: confirmedPlayerIds ?? this.confirmedPlayerIds,
      courtId: courtId ?? this.courtId,
      clubId: clubId ?? this.clubId,
      format: format ?? this.format,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      private: private ?? this.private,
      ownerId: ownerId ?? this.ownerId,
      requests: requests ?? this.requests,
      restrictions: restrictions ?? this.restrictions,
      status: status ?? this.status,
      title: title ?? this.title,
      clubName: clubName ?? this.clubName,
      courtName: courtName ?? this.courtName,
      clubPin: clubPin ?? this.clubPin,
      courtPin: courtPin ?? this.courtPin,
    );
  }

  @override
  bool operator ==(covariant Booking other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.confirmedPlayerIds == confirmedPlayerIds &&
        other.courtId == courtId &&
        other.clubId == clubId &&
        other.format == format &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.private == private &&
        other.ownerId == ownerId &&
        other.requests == requests &&
        other.restrictions == restrictions &&
        other.status == status &&
        other.title == title &&
        other.clubName == clubName &&
        other.courtName == courtName &&
        other.clubPin == clubPin &&
        other.courtPin == courtPin;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        confirmedPlayerIds.hashCode ^
        courtId.hashCode ^
        clubId.hashCode ^
        format.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        private.hashCode ^
        ownerId.hashCode ^
        requests.hashCode ^
        restrictions.hashCode ^
        status.hashCode ^
        title.hashCode ^
        clubName.hashCode ^
        courtName.hashCode ^
        clubPin.hashCode ^
        courtPin.hashCode;
  }

  @override
  FirestorePayload toJson() => {
        BookingFields.id: id,
        BookingFields.confirmedPlayerIds: confirmedPlayerIds,
        BookingFields.courtId: courtId,
        BookingFields.clubId: clubId,
        BookingFields.format: format.name,
        BookingFields.startTime: startTime,
        BookingFields.endTime: endTime,
        BookingFields.private: private,
        BookingFields.ownerId: ownerId,
        BookingFields.requests: requests.map((x) => x.toJson()).toList(),
        BookingFields.restrictions: restrictions?.toJson(),
        BookingFields.status: status.name,
        BookingFields.clubName: clubName,
        BookingFields.courtName: courtName,
        BookingFields.title: title,
      };
}
