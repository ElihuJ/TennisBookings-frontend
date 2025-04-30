import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../index.dart';

final _defaultId = getUuid();
final _defaultName = 'Problem loading Populated Booking';
final _defaultClubName = 'Problem loading Club Name';
final _defaultCourtName = 'Problem loading Court Name';

/*
* This class extends standard booking using populated requests rather than normal one
* which will contain additional user data which is used when displaying the booking request
*/
class BookingWithPopulatedRequest extends Booking {
  // The constructor takes the extended list type.

  @override
  // * Overriding the requests property to be of type List<BookingPopulatedRequest>
  // ignore: overridden_fields
  final List<BookingPopulatedRequest> requests;

  BookingWithPopulatedRequest({
    required super.id,
    required super.confirmedPlayerIds,
    required super.courtId,
    required super.clubId,
    required super.format,
    required super.startTime,
    required super.endTime,
    required super.private,
    required super.ownerId,
    super.restrictions,
    required super.status,
    required this.requests,
    required super.title,
    required super.clubName,
    required super.courtName,
    super.mergedBookings = const [],
  }) : super(requests: requests);

  BookingWithPopulatedRequest.empty()
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
          restrictions: null,
          status: BookingStatus.open,
          title: _defaultName,
          requests: [],
          clubName: _defaultClubName,
          courtName: _defaultCourtName,
        );

  factory BookingWithPopulatedRequest.fromJson(Map<String, dynamic> json) {
    try {
      // * Verify required props
      final id = verifyRequiredProp<String>(prop: json[BookingFields.id], propName: BookingFields.id, defaultValue: _defaultId);
      final confirmedPlayerIdsRaw =
          verifyRequiredProp<List>(prop: json[BookingFields.confirmedPlayerIds], propName: BookingFields.confirmedPlayerIds, defaultValue: []);
      final courtId = verifyRequiredProp<String>(prop: json[BookingFields.courtId], propName: BookingFields.courtId, defaultValue: _defaultId);
      final clubId = verifyRequiredProp<String>(prop: json[BookingFields.clubId], propName: BookingFields.clubId, defaultValue: _defaultId);
      final startTime = verifyRequiredProp<int>(prop: json[BookingFields.startTime], propName: BookingFields.startTime, defaultValue: 0);
      final endTime = verifyRequiredProp<int>(prop: json[BookingFields.endTime], propName: BookingFields.endTime, defaultValue: 0);
      final private = verifyRequiredProp<bool>(prop: json[BookingFields.private], propName: BookingFields.private, defaultValue: false);
      final ownerId = verifyRequiredProp<String>(prop: json[BookingFields.ownerId], propName: BookingFields.ownerId, defaultValue: _defaultId);
      final title = verifyRequiredProp<String>(prop: json[BookingFields.title], propName: BookingFields.title, defaultValue: _defaultName);
      final clubName =
          verifyRequiredProp<String>(prop: json[BookingFields.clubName], propName: BookingFields.clubName, defaultValue: _defaultClubName);
      final courtName =
          verifyRequiredProp<String>(prop: json[BookingFields.courtName], propName: BookingFields.courtName, defaultValue: _defaultCourtName);

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
        startTime: startTime,
        endTime: endTime,
        private: private,
        ownerId: ownerId,
        requests: populatedRequests, // Use the extended list type
        restrictions: restrictions,
        status: status,
        title: title,
        clubName: clubName,
        courtName: courtName,
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
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.private == private &&
        other.ownerId == ownerId &&
        other.requests == requests &&
        other.restrictions == restrictions &&
        other.status == status &&
        other.clubName == clubName &&
        other.courtName == courtName &&
        other.title == title;
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
        clubName.hashCode ^
        courtName.hashCode ^
        title.hashCode;
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
        BookingFields.restrictions: restrictions,
        BookingFields.status: status.name,
        BookingFields.clubName: clubName,
        BookingFields.courtName: courtName,
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
        clubName: $clubName,
        courtName: $courtName,
        startTime: $startTime,
        endTime: $endTime,
        private: $private,
        ownerId: $ownerId,
        requests: $requests,
        restrictions: $restrictions,
        status: $status,
        title: $title
      )''';
  }
}
