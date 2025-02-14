import 'dart:collection';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../index.dart';

final defaultId = getUuid();
final defaultName = 'Problem loading Booking';

class Booking extends MapView<String, dynamic> implements FirestoreModel, HasId {
  @override
  final String id;
  final List<String> confirmedPlayerIds;
  final String courtId;
  final String clubId;
  final BookingFormat format;
  final int from;
  final int to;
  final bool private;
  final String ownerId;
  final List<BookingRequest> requests;
  final BookingRestrictions? restrictions;
  final BookingStatus status;
  final String title;
  final List<Booking> mergedBookings; // * Used for calendar view ONLY FRONTEND. No DB

  @override
  final List<String> allFields = BookingFields.allFields;

  Booking({
    required this.id,
    required this.confirmedPlayerIds,
    required this.courtId,
    required this.clubId,
    required this.format,
    required this.from,
    required this.to,
    required this.private,
    required this.ownerId,
    required this.requests,
    this.restrictions,
    required this.status,
    required this.title,
    this.mergedBookings = const [],
  }) : super({
          BookingFields.id: id,
          BookingFields.confirmedPlayerIds: confirmedPlayerIds,
          BookingFields.courtId: courtId,
          BookingFields.clubId: clubId,
          BookingFields.format: format,
          BookingFields.from: from,
          BookingFields.to: to,
          BookingFields.private: private,
          BookingFields.ownerId: ownerId,
          BookingFields.requests: requests,
          BookingFields.restrictions: restrictions,
          BookingFields.status: status,
          BookingFields.title: title,
        });

  Booking.empty()
      : this(
          id: defaultId,
          confirmedPlayerIds: [],
          courtId: defaultId,
          clubId: defaultId,
          format: BookingFormat.singles,
          from: 0,
          to: 0,
          private: false,
          ownerId: defaultId,
          requests: [],
          restrictions: null,
          status: BookingStatus.open,
          title: defaultName,
        );

  factory Booking.fromJson(Map<String, dynamic> json) {
    try {
      // * Verify required props
      final id = verifyRequiredProp<String>(prop: json[BookingFields.id], propName: BookingFields.id, defaultValue: defaultId);
      final confirmedPlayerIdsRaw =
          verifyRequiredProp<List>(prop: json[BookingFields.confirmedPlayerIds], propName: BookingFields.confirmedPlayerIds, defaultValue: []);
      final courtId = verifyRequiredProp<String>(prop: json[BookingFields.courtId], propName: BookingFields.courtId, defaultValue: defaultId);
      final clubId = verifyRequiredProp<String>(prop: json[BookingFields.clubId], propName: BookingFields.clubId, defaultValue: defaultId);
      final from = verifyRequiredProp<int>(prop: json[BookingFields.from], propName: BookingFields.from, defaultValue: 0);
      final to = verifyRequiredProp<int>(prop: json[BookingFields.to], propName: BookingFields.to, defaultValue: 0);
      final private = verifyRequiredProp<bool>(prop: json[BookingFields.private], propName: BookingFields.private, defaultValue: false);
      final ownerId = verifyRequiredProp<String>(prop: json[BookingFields.ownerId], propName: BookingFields.ownerId, defaultValue: defaultId);
      final title = verifyRequiredProp<String>(prop: json[BookingFields.title], propName: BookingFields.title, defaultValue: defaultName);

      final List<BookingRequest> requests =
          json[BookingFields.requests] != null ? List<BookingRequest>.from(json[BookingFields.requests].map((x) => BookingRequest.fromJson(x))) : [];
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
        from: from,
        to: to,
        private: private,
        ownerId: ownerId,
        requests: requests,
        restrictions: restrictions,
        status: status,
        title: title,
      );
    } catch (e) {
      e.tbLogger('1 ERROR CONSTRUCTING BOOKING', DebugLevel.error);
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
    int? from,
    int? to,
    bool? private,
    String? ownerId,
    List<BookingRequest>? requests,
    BookingRestrictions? restrictions,
    BookingStatus? status,
    String? title,
  }) {
    return Booking(
      id: id ?? this.id,
      confirmedPlayerIds: confirmedPlayerIds ?? this.confirmedPlayerIds,
      courtId: courtId ?? this.courtId,
      clubId: clubId ?? this.clubId,
      format: format ?? this.format,
      from: from ?? this.from,
      to: to ?? this.to,
      private: private ?? this.private,
      ownerId: ownerId ?? this.ownerId,
      requests: requests ?? this.requests,
      restrictions: restrictions ?? this.restrictions,
      status: status ?? this.status,
      title: title ?? this.title,
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
        other.from == from &&
        other.to == to &&
        other.private == private &&
        other.ownerId == ownerId &&
        other.requests == requests &&
        other.restrictions == restrictions &&
        other.status == status &&
        other.title == title;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        confirmedPlayerIds.hashCode ^
        courtId.hashCode ^
        clubId.hashCode ^
        format.hashCode ^
        from.hashCode ^
        to.hashCode ^
        private.hashCode ^
        ownerId.hashCode ^
        requests.hashCode ^
        restrictions.hashCode ^
        status.hashCode ^
        title.hashCode;
  }

  @override
  FirestorePayload toJson() => {
        BookingFields.id: id,
        BookingFields.confirmedPlayerIds: confirmedPlayerIds,
        BookingFields.courtId: courtId,
        BookingFields.clubId: clubId,
        BookingFields.format: format.name,
        BookingFields.from: from,
        BookingFields.to: to,
        BookingFields.private: private,
        BookingFields.ownerId: ownerId,
        BookingFields.requests: requests.map((x) => x.toJson()).toList(),
        BookingFields.restrictions: restrictions,
        BookingFields.status: status.name,
        BookingFields.title: title,
      };
}
