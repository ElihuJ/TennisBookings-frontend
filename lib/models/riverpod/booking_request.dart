import 'dart:collection';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../index.dart';

final defaultBookingRequestId = getUuid();

class BookingRequest extends MapView<String, dynamic> implements FirestoreModel {
  final String playerId;
  final BookingRequestStatus status;

  @override
  final List<String> allFields = BookingRequestFields.allFields;

  BookingRequest({
    required this.playerId,
    required this.status,
  }) : super({
          BookingRequestFields.playerId: playerId,
          BookingRequestFields.status: status,
        });

  BookingRequest.empty()
      : this(
          playerId: defaultBookingRequestId,
          status: BookingRequestStatus.pending,
        );

  @override
  BookingRequest copyWith({
    String? playerId,
    BookingRequestStatus? status,
  }) {
    return BookingRequest(
      playerId: playerId ?? this.playerId,
      status: status ?? this.status,
    );
  }

  @override
  FirestorePayload toJson() {
    return {
      BookingRequestFields.playerId: playerId,
      BookingRequestFields.status: status.name,
    };
  }

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    try {
      // * Verify required props
      final playerId = verifyRequiredProp<String>(
          prop: json[BookingRequestFields.playerId], propName: BookingRequestFields.playerId, defaultValue: defaultBookingRequestId);
      final status = BookingRequestStatus.fromString(json[BookingRequestFields.status]);

      verifyProps(json, BookingRequestFields.allFields);

      return BookingRequest(
        playerId: playerId,
        status: status,
      );
    } catch (e) {
      e.tbLogger('ERROR CONSTRUCTING BOOKING REQUEST', DebugLevel.error);
      return BookingRequest.empty();
    }
  }
}
