import 'dart:collection';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../index.dart';

final defaultId = getUuid();
final defaultName = 'Problem loading Booking';

class Booking extends MapView<String, dynamic> implements FirestoreModel {
  final String id;
  final List<String> confirmedPlayerIds;
  final String courtId;
  final BookingFormat format;
  final int from;
  final int to;
  final bool isPrivate;
  final String ownerId;
  final List<BookingRequest> requests;
  final List<BookingRestrictions> restrictions;
  final BookingStatus status;

  @override
  final List<String> allFields = BookingFields.allFields;

  Booking({
    required this.id,
    required this.confirmedPlayerIds,
    required this.courtId,
    required this.format,
    required this.from,
    required this.to,
    required this.isPrivate,
    required this.ownerId,
    required this.requests,
    required this.restrictions,
    required this.status,
  }) : super({
          BookingFields.id: id,
          BookingFields.confirmedPlayerIds: confirmedPlayerIds,
          BookingFields.courtId: courtId,
          BookingFields.format: format,
          BookingFields.from: from,
          BookingFields.to: to,
          BookingFields.isPrivate: isPrivate,
          BookingFields.ownerId: ownerId,
          BookingFields.requests: requests,
          BookingFields.restrictions: restrictions,
          BookingFields.status: status,
        });

  Booking.empty()
      : this(
          id: defaultId,
          confirmedPlayerIds: [],
          courtId: defaultId,
          format: BookingFormat.singles,
          from: 0,
          to: 0,
          isPrivate: false,
          ownerId: defaultId,
          requests: [],
          restrictions: [],
          status: BookingStatus.open,
        );

  factory Booking.fromJson(Map<String, dynamic> json) {
    try {
      // * Verify required props
      final id = verifyRequiredProp<String>(prop: json[BookingFields.id], propName: BookingFields.id, defaultValue: defaultId);
      final confirmedPlayerIdsRaw =
          verifyRequiredProp<List>(prop: json[BookingFields.confirmedPlayerIds], propName: BookingFields.confirmedPlayerIds, defaultValue: []);
      final courtId = verifyRequiredProp<String>(prop: json[BookingFields.courtId], propName: BookingFields.courtId, defaultValue: defaultId);
      final from = verifyRequiredProp<int>(prop: json[BookingFields.from], propName: BookingFields.from, defaultValue: 0);
      final to = verifyRequiredProp<int>(prop: json[BookingFields.to], propName: BookingFields.to, defaultValue: 0);
      final isPrivate = verifyRequiredProp<bool>(prop: json[BookingFields.isPrivate], propName: BookingFields.isPrivate, defaultValue: false);
      final ownerId = verifyRequiredProp<String>(prop: json[BookingFields.ownerId], propName: BookingFields.ownerId, defaultValue: defaultId);

      final List<BookingRequest> requests =
          json[BookingFields.requests] != null ? List<BookingRequest>.from(json[BookingFields.requests].map((x) => BookingRequest.fromJson(x))) : [];
      final List<BookingRestrictions> restrictions = json[BookingFields.restrictions] != null
          ? List<BookingRestrictions>.from(json[BookingFields.restrictions].map((x) => BookingRestrictions.fromJson(x)))
          : [];
      final status = json[BookingFields.status] != null ? BookingStatus.fromString(json[BookingFields.status]) : BookingStatus.unknown;
      final format = json[BookingFields.format] != null ? BookingFormat.fromString(json[BookingFields.format]) : BookingFormat.unknown;

      final List<String> confirmedPlayerIds = List<String>.from(confirmedPlayerIdsRaw);

      verifyProps(json, BookingFields.allFields);

      return Booking(
          id: id,
          confirmedPlayerIds: confirmedPlayerIds,
          courtId: courtId,
          format: format,
          from: from,
          to: to,
          isPrivate: isPrivate,
          ownerId: ownerId,
          requests: requests,
          restrictions: restrictions,
          status: status);
    } catch (e) {
      e.tbLogger('1 ERROR CONSTRUCTING BOOKING', DebugLevel.error);
      return Booking.empty();
    }
  }

  @override
  Booking copyWith({
    String? id,
    List<String>? confirmedPlayerIds,
    String? courtId,
    BookingFormat? format,
    int? from,
    int? to,
    bool? isPrivate,
    String? ownerId,
    List<BookingRequest>? requests,
    List<BookingRestrictions>? restrictions,
    BookingStatus? status,
  }) {
    return Booking(
      id: id ?? this.id,
      confirmedPlayerIds: confirmedPlayerIds ?? this.confirmedPlayerIds,
      courtId: courtId ?? this.courtId,
      format: format ?? this.format,
      from: from ?? this.from,
      to: to ?? this.to,
      isPrivate: isPrivate ?? this.isPrivate,
      ownerId: ownerId ?? this.ownerId,
      requests: requests ?? this.requests,
      restrictions: restrictions ?? this.restrictions,
      status: status ?? this.status,
    );
  }

  @override
  FirestorePayload toJson() => {
        BookingFields.id: id,
        BookingFields.confirmedPlayerIds: confirmedPlayerIds,
        BookingFields.courtId: courtId,
        BookingFields.format: format.name,
        BookingFields.from: from,
        BookingFields.to: to,
        BookingFields.isPrivate: isPrivate,
        BookingFields.ownerId: ownerId,
        BookingFields.requests: requests.map((x) => x.toJson()).toList(),
        BookingFields.restrictions: restrictions.map((x) => x.toJson()).toList(),
        BookingFields.status: status.name,
      };
}
