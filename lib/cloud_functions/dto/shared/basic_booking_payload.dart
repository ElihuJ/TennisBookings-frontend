import '../../../global_helpers/index.dart';

class BasicBookingPayload implements APIPayload {
  static final getConfirmedPlayersDataEndpoint = 'getConfirmedPlayersData';
  static final deleteBookingEndpoint = 'deleteBooking';

  final String bookingId;
  final String clubId;
  final String courtId;

  BasicBookingPayload({required this.bookingId, required this.clubId, required this.courtId});

  @override
  Map<String, dynamic> toJson() {
    return {'bookingId': bookingId, 'clubId': clubId, 'courtId': courtId};
  }

  @override
  String toString() {
    return 'BasicBookingPayload(bookingId: $bookingId, clubId: $clubId, courtId: $courtId)';
  }
}
