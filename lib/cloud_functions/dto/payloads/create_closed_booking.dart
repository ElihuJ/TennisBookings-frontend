import '../../../global_helpers/index.dart';
import '../../../models/riverpod/index.dart';

class CreateBookingPayload implements APIPayload {
  final Booking booking;
  final String clubId;
  final bool isOpenBooking;
  static final endpoint = 'createBooking';

  CreateBookingPayload({
    required this.booking,
    required this.clubId,
    required this.isOpenBooking,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'booking': booking.toJson(),
      'clubId': clubId,
      'isOpenBooking': isOpenBooking,
    };
  }
}
