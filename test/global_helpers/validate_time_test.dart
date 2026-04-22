import 'package:flutter_test/flutter_test.dart';
import 'package:tennisbookings/global_helpers/validators.dart';
import 'package:tennisbookings/global_types/types.dart';

void main() {
  group('validateTime', () {
    final booked = BookedTimeEpoch(1000, 2000);

    test('returns true when no bookings exist', () {
      expect(validateTime(startTimeEpoch: 500, bookedTimes: [], endTimeEpoch: 900), isTrue);
    });

    test('returns true when slot is entirely before booked time', () {
      expect(validateTime(startTimeEpoch: 0, bookedTimes: [booked], endTimeEpoch: 1000), isTrue);
    });

    test('returns true when slot is entirely after booked time', () {
      expect(validateTime(startTimeEpoch: 2000, bookedTimes: [booked], endTimeEpoch: 3000), isTrue);
    });

    test('returns false when start is inside booked time', () {
      expect(validateTime(startTimeEpoch: 1500, bookedTimes: [booked], endTimeEpoch: 2500), isFalse);
    });

    test('returns false when end is inside booked time', () {
      expect(validateTime(startTimeEpoch: 500, bookedTimes: [booked], endTimeEpoch: 1500), isFalse);
    });

    test('returns false when slot wraps around booked time', () {
      expect(validateTime(startTimeEpoch: 500, bookedTimes: [booked], endTimeEpoch: 2500), isFalse);
    });

    test('returns false when slot is exactly the booked time', () {
      expect(validateTime(startTimeEpoch: 1000, bookedTimes: [booked], endTimeEpoch: 2000), isFalse);
    });

    test('boundary: start exactly at booked end is valid', () {
      expect(validateTime(startTimeEpoch: 2000, bookedTimes: [booked], endTimeEpoch: 3000), isTrue);
    });

    test('boundary: end exactly at booked start is valid', () {
      expect(validateTime(startTimeEpoch: 0, bookedTimes: [booked], endTimeEpoch: 1000), isTrue);
    });

    test('returns false when overlapping any booking in multiple bookings', () {
      final bookings = [BookedTimeEpoch(1000, 2000), BookedTimeEpoch(3000, 4000)];
      expect(validateTime(startTimeEpoch: 2500, bookedTimes: bookings, endTimeEpoch: 3500), isFalse);
    });
  });
}
