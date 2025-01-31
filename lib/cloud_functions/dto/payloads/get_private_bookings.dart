import '../../../global_helpers/index.dart';

class GetPrivateBookingsPayload implements APIPayload {
  static final endpoint = 'getPrivateBookings';

  final bool getAll;
  final String? clubId;
  final String? courtId;

  GetPrivateBookingsPayload({required this.getAll, this.clubId, this.courtId});

  @override
  Map<String, dynamic> toJson() {
    return {'getAll': getAll, 'clubId': clubId, 'courtId': courtId};
  }
}
