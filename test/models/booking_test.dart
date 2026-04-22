import 'package:flutter_test/flutter_test.dart';
import 'package:tennisbookings/global_types/enums.dart';
import 'package:tennisbookings/models/riverpod/booking.dart';

Map<String, dynamic> _validJson() => {
      'id': 'booking1',
      'courtId': 'court1',
      'clubId': 'club1',
      'ownerId': 'owner1',
      'startTime': 1000,
      'endTime': 2000,
      'status': 'open',
      'format': 'singles',
      'private': false,
      'confirmedPlayerIds': [],
      'requests': [],
      'restrictions': null,
      'title': 'Test Booking',
      'clubName': 'Test Club',
      'courtName': 'Court 1',
      'clubPin': null,
      'courtPin': null,
    };

void main() {
  group('Booking.fromJson', () {
    test('parses valid JSON correctly', () {
      final booking = Booking.fromJson(_validJson());
      expect(booking.id, 'booking1');
      expect(booking.courtId, 'court1');
      expect(booking.clubId, 'club1');
      expect(booking.ownerId, 'owner1');
      expect(booking.startTime, 1000);
      expect(booking.endTime, 2000);
      expect(booking.status, BookingStatus.open);
      expect(booking.format, BookingFormat.singles);
      expect(booking.private, isFalse);
      expect(booking.title, 'Test Booking');
    });

    test('handles missing optional pins gracefully', () {
      final json = _validJson()..remove('clubPin')..remove('courtPin');
      final booking = Booking.fromJson(json);
      expect(booking.clubPin, isNull);
      expect(booking.courtPin, isNull);
    });

    test('parses status correctly for all values', () {
      for (final entry in {
        'open': BookingStatus.open,
        'confirmed': BookingStatus.confirmed,
        'cancelled': BookingStatus.cancelled,
        'overridden': BookingStatus.overridden,
      }.entries) {
        final json = _validJson()..[BookingFields.status] = entry.key;
        expect(Booking.fromJson(json).status, entry.value);
      }
    });

    test('parses format correctly for all values', () {
      for (final entry in {
        'singles': BookingFormat.singles,
        'doubles': BookingFormat.doubles,
        'coaching': BookingFormat.coaching,
      }.entries) {
        final json = _validJson()..[BookingFields.format] = entry.key;
        expect(Booking.fromJson(json).format, entry.value);
      }
    });

    test('accepts numeric startTime/endTime as num (web Firestore compat)', () {
      final json = _validJson()
        ..[BookingFields.startTime] = 1000.0
        ..[BookingFields.endTime] = 2000.0;
      final booking = Booking.fromJson(json);
      expect(booking.startTime, 1000);
      expect(booking.endTime, 2000);
    });
  });

  group('Booking.copyWith', () {
    late Booking original;

    setUp(() {
      original = Booking.fromJson(_validJson());
    });

    test('copies without changes when no args provided', () {
      final copy = original.copyWith();
      expect(copy.id, original.id);
      expect(copy.status, original.status);
    });

    test('updates only the specified field', () {
      final copy = original.copyWith(status: BookingStatus.confirmed);
      expect(copy.status, BookingStatus.confirmed);
      expect(copy.id, original.id);
      expect(copy.courtId, original.courtId);
    });

    test('updates startTime and endTime independently', () {
      final copy = original.copyWith(startTime: 5000, endTime: 6000);
      expect(copy.startTime, 5000);
      expect(copy.endTime, 6000);
      expect(copy.ownerId, original.ownerId);
    });
  });

  group('BookingStatus.fromString', () {
    test('returns correct enum for known strings', () {
      expect(BookingStatus.fromString('open'), BookingStatus.open);
      expect(BookingStatus.fromString('confirmed'), BookingStatus.confirmed);
      expect(BookingStatus.fromString('cancelled'), BookingStatus.cancelled);
      expect(BookingStatus.fromString('overridden'), BookingStatus.overridden);
    });

    test('returns unknown for unrecognized string', () {
      expect(BookingStatus.fromString('invalid'), BookingStatus.unknown);
    });
  });
}

class BookingFields {
  static const String id = 'id';
  static const String courtId = 'courtId';
  static const String ownerId = 'ownerId';
  static const String startTime = 'startTime';
  static const String endTime = 'endTime';
  static const String status = 'status';
  static const String format = 'format';
}
