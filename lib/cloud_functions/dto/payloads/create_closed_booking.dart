import '../../../global_helpers/index.dart';
import '../../../models/riverpod/index.dart';

class CreateClosedBookingPayload implements APIPayload {
  final Booking booking;
  final String clubId;
  static final endpoint = 'createClosedBooking';

  CreateClosedBookingPayload({
    required this.booking,
    required this.clubId,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'booking': booking.toJson(),
      'clubId': clubId,
    };
  }
}
