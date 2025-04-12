import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../index.dart';

final _defaultId = getUuid();
final _defaultName = 'Problem loading Populated Booking';

/*
* This class extends standard booking using populated requests rather than normal one
* which will contain additional user data
*/
class BookingWithPopulatedRequest extends Booking {
  // The constructor takes the extended list type.
  BookingWithPopulatedRequest({
    required super.id,
    required super.confirmedPlayerIds,
    required super.courtId,
    required super.clubId,
    required super.format,
    required super.from,
    required super.to,
    required super.private,
    required super.ownerId,
    super.restrictions,
    required super.status,
    required super.requests,
    required super.title,
    super.mergedBookings = const [],
  }) : super() {
    // Initialize the requests property with an empty list.
    // This is necessary because the parent class requires it.
  }

  BookingWithPopulatedRequest.empty()
      : this(
          id: _defaultId,
          confirmedPlayerIds: [],
          courtId: _defaultId,
          clubId: _defaultId,
          format: BookingFormat.singles,
          from: 0,
          to: 0,
          private: false,
          ownerId: defaultId,
          restrictions: null,
          status: BookingStatus.open,
          title: _defaultName,
          requests: [],
        );

  factory BookingWithPopulatedRequest.fromJson(Map<String, dynamic> json) {
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
      final title = verifyRequiredProp<String>(prop: json[BookingFields.title], propName: BookingFields.title, defaultValue: _defaultName);

      // * Structure is different from regular booking request but property is named same
      final List<BookingPopulatedRequest> populatedRequests = json[BookingFields.requests] != null
          ? List<BookingPopulatedRequest>.from(json[BookingFields.requests].map((x) => BookingPopulatedRequest.fromJson(x)))
          : [];
      final BookingRestrictions? restrictions =
          json[BookingFields.restrictions] != null ? BookingRestrictions.fromJson(json[BookingFields.restrictions]) : null;
      final status = json[BookingFields.status] != null ? BookingStatus.fromString(json[BookingFields.status]) : BookingStatus.unknown;
      final format = json[BookingFields.format] != null ? BookingFormat.fromString(json[BookingFields.format]) : BookingFormat.unknown;

      final List<String> confirmedPlayerIds = List<String>.from(confirmedPlayerIdsRaw);

      verifyProps(json, BookingFields.allFields);

      final booking = BookingWithPopulatedRequest(
        id: id,
        confirmedPlayerIds: confirmedPlayerIds,
        courtId: courtId,
        clubId: clubId,
        format: format,
        from: from,
        to: to,
        private: private,
        ownerId: ownerId,
        requests: populatedRequests, // Use the extended list type
        restrictions: restrictions,
        status: status,
        title: title,
      );

      return booking;
    } catch (e) {
      e.tbLogger('ERROR CONSTRUCTING POPULATED BOOKING', DebugLevel.error);
      return BookingWithPopulatedRequest.empty();
    }
  }

  @override
  bool operator ==(covariant BookingWithPopulatedRequest other) {
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

  @override
  String toString() {
    return '''
      BookingWithPopulatedRequest(
        id: $id,
        confirmedPlayerIds: $confirmedPlayerIds,
        courtId: $courtId,
        clubId: $clubId,
        format: $format,
        from: $from,
        to: $to,
        private: $private,
        ownerId: $ownerId,
        requests: $requests,
        restrictions: $restrictions,
        status: $status,
        title: $title
      )''';
  }
}
