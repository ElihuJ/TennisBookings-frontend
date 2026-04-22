import 'package:flutter_test/flutter_test.dart';
import 'package:tennisbookings/global_helpers/bookings.dart';
import 'package:tennisbookings/global_types/enums.dart';
import 'package:tennisbookings/models/riverpod/booking.dart';
import 'package:tennisbookings/models/riverpod/booking_restrictions.dart';
import 'package:tennisbookings/state/user/user_state.dart';

Booking _booking({
  BookingStatus status = BookingStatus.open,
  BookingRestrictions? restrictions,
  String ownerId = 'owner1',
  List<String> confirmedPlayerIds = const [],
}) {
  return Booking(
    id: 'b1',
    confirmedPlayerIds: confirmedPlayerIds,
    courtId: 'court1',
    clubId: 'club1',
    format: BookingFormat.singles,
    startTime: 1000,
    endTime: 2000,
    private: false,
    ownerId: ownerId,
    requests: [],
    restrictions: restrictions,
    status: status,
    title: 'Test',
    clubName: 'Club',
    courtName: 'Court 1',
  );
}

User _user({
  String uid = 'user1',
  double? utrRating,
  bool utrVerified = false,
  Gender? gender,
}) {
  return User(
    uid: uid,
    accountCreationDate: 0,
    bookings: [],
    dob: 0,
    email: 'test@test.com',
    gender: gender ?? Gender.unknown,
    lastLogin: 0,
    name: 'Test User',
    photoUrl: '',
    utrRating: utrRating,
    utrVerified: utrVerified,
    memberships: [],
    stripeClubDetails: [],
  );
}

void main() {
  group('filterRestrictedBookings', () {
    test('returns all bookings when no restrictions', () {
      final bookings = [_booking(), _booking()];
      final result = filterRestrictedBookings(bookings: bookings);
      expect(result.length, 2);
    });

    test('confirmed bookings always pass regardless of restrictions', () {
      final booking = _booking(
        status: BookingStatus.confirmed,
        restrictions: BookingRestrictions(utrVerified: true, utrGt: 10),
      );
      final result = filterRestrictedBookings(bookings: [booking]);
      expect(result.length, 1);
    });

    test('null user is blocked when booking has restrictions', () {
      final booking = _booking(restrictions: BookingRestrictions(utrVerified: false));
      final result = filterRestrictedBookings(bookings: [booking]);
      expect(result, isEmpty);
    });

    test('owner always passes even with restrictions', () {
      final booking = _booking(
        ownerId: 'user1',
        restrictions: BookingRestrictions(utrVerified: true, utrGt: 10),
      );
      final user = _user(uid: 'user1');
      final result = filterRestrictedBookings(bookings: [booking], user: user);
      expect(result.length, 1);
    });

    test('confirmed player always passes even with restrictions', () {
      final booking = _booking(
        confirmedPlayerIds: ['user1'],
        restrictions: BookingRestrictions(utrVerified: true, utrGt: 10),
      );
      final user = _user(uid: 'user1');
      final result = filterRestrictedBookings(bookings: [booking], user: user);
      expect(result.length, 1);
    });

    test('user without utrRating is blocked by restrictions', () {
      final booking = _booking(restrictions: BookingRestrictions(utrVerified: false));
      final user = _user(utrRating: null);
      final result = filterRestrictedBookings(bookings: [booking], user: user);
      expect(result, isEmpty);
    });

    test('utrVerified restriction blocks unverified user', () {
      final booking = _booking(restrictions: BookingRestrictions(utrVerified: true));
      final user = _user(utrRating: 5.0, utrVerified: false);
      final result = filterRestrictedBookings(bookings: [booking], user: user);
      expect(result, isEmpty);
    });

    test('utrVerified restriction passes verified user', () {
      final booking = _booking(restrictions: BookingRestrictions(utrVerified: true));
      final user = _user(utrRating: 5.0, utrVerified: true);
      final result = filterRestrictedBookings(bookings: [booking], user: user);
      expect(result.length, 1);
    });

    test('utrGt blocks user below minimum', () {
      final booking = _booking(restrictions: BookingRestrictions(utrVerified: false, utrGt: 6.0));
      final user = _user(utrRating: 5.0);
      final result = filterRestrictedBookings(bookings: [booking], user: user);
      expect(result, isEmpty);
    });

    test('utrLt blocks user above maximum', () {
      final booking = _booking(restrictions: BookingRestrictions(utrVerified: false, utrLt: 4.0));
      final user = _user(utrRating: 5.0);
      final result = filterRestrictedBookings(bookings: [booking], user: user);
      expect(result, isEmpty);
    });

    test('gender restriction blocks wrong gender', () {
      final booking = _booking(restrictions: BookingRestrictions(utrVerified: false, gender: Gender.female));
      final user = _user(utrRating: 5.0, gender: Gender.male);
      final result = filterRestrictedBookings(bookings: [booking], user: user);
      expect(result, isEmpty);
    });

    test('gender restriction passes matching gender', () {
      final booking = _booking(restrictions: BookingRestrictions(utrVerified: false, gender: Gender.female));
      final user = _user(utrRating: 5.0, gender: Gender.female);
      final result = filterRestrictedBookings(bookings: [booking], user: user);
      expect(result.length, 1);
    });
  });
}
