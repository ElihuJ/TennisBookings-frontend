import '../global_types/index.dart';
import '../models/index.dart';
import '../state/index.dart';

List<Booking> filterRestrictedBookings({required List<Booking> bookings, User? user}) {
  return bookings.where((booking) {
    if (booking.status == BookingStatus.confirmed) return true;

    // * No restrictions or user is owner/confirmed player
    if (booking.restrictions == null || (user != null && (booking.ownerId == user.uid || booking.confirmedPlayerIds.contains(user.uid)))) {
      return true;
    }

    final restrictions = booking.restrictions!;

    // * Must be logged in with UTR rating to view restricted bookings
    if (user == null || user.utrRating == null) {
      return false;
    }

    // * Check UTR verification
    if (restrictions.utrVerified && !user.utrVerified) {
      return false;
    }

    // * Check UTR rating range
    if (restrictions.utrGt != null && user.utrRating! < restrictions.utrGt!) {
      return false;
    }

    if (restrictions.utrLt != null && user.utrRating! > restrictions.utrLt!) {
      return false;
    }

    if (!_isValidGender(restriction: restrictions.gender, userGender: user.gender)) {
      return false;
    }

    return true;
  }).toList();
}

bool _isValidGender({
  required Gender? restriction,
  required Gender? userGender,
}) {
  if (restriction == null || restriction == Gender.unknown) {
    return true;
  }
  if (userGender == null) {
    return false;
  }
  if (restriction != userGender) {
    return false;
  }
  return true;
}
