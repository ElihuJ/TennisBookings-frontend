import '../../../global_helpers/index.dart';

class GetConfirmedPlayersDataPayload implements APIPayload {
  static final endpoint = 'getConfirmedPlayersData';

  final String bookingId;
  final String clubId;
  final String courtId;

  GetConfirmedPlayersDataPayload({required this.bookingId, required this.clubId, required this.courtId});

  @override
  Map<String, dynamic> toJson() {
    return {'bookingId': bookingId, 'clubId': clubId, 'courtId': courtId};
  }

  @override
  String toString() {
    return 'GetConfirmedPlayersDataPayload(bookingId: $bookingId, clubId: $clubId, courtId: $courtId)';
  }
}
