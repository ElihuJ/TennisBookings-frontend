import '../models/index.dart';
import '../state/index.dart';

List<Booking> filterRestrictedBookings({required List<Booking> bookings, User? user}) {
  final notLoggedInOrNoUtr = user == null || user.utrRating == null;
  final bookingsCopy = [...bookings];

  for (final booking in bookingsCopy) {
    if (booking.restrictions != null) {
      if (booking.ownerId == user?.uid || booking.confirmedPlayerIds.contains(user?.uid)) {
        continue;
      }
      if (notLoggedInOrNoUtr) {
        bookings.remove(booking);
        continue;
      }

      final restrictions = booking.restrictions!;
      if (restrictions.utrVerified && !user.utrVerified) {
        bookings.remove(booking);
        continue;
      }
      if (user.utrRating! < restrictions.utrGt || user.utrRating! > restrictions.utrLt) {
        bookings.remove(booking);
        continue;
      }
    }
  }
  return bookings;
}
