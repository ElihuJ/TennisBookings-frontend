import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tennisbookings/global_helpers/time_helpers.dart';

void main() {
  group('roundToNearestQuarter', () {
    test('0–14 minutes rounds to 0', () {
      expect(roundToNearestQuarter(const TimeOfDay(hour: 10, minute: 0)).minute, 0);
      expect(roundToNearestQuarter(const TimeOfDay(hour: 10, minute: 14)).minute, 0);
    });

    test('15–29 minutes rounds to 15', () {
      expect(roundToNearestQuarter(const TimeOfDay(hour: 10, minute: 15)).minute, 15);
      expect(roundToNearestQuarter(const TimeOfDay(hour: 10, minute: 29)).minute, 15);
    });

    test('30–44 minutes rounds to 30', () {
      expect(roundToNearestQuarter(const TimeOfDay(hour: 10, minute: 30)).minute, 30);
      expect(roundToNearestQuarter(const TimeOfDay(hour: 10, minute: 44)).minute, 30);
    });

    test('45–59 minutes rounds to 45', () {
      expect(roundToNearestQuarter(const TimeOfDay(hour: 10, minute: 45)).minute, 45);
      expect(roundToNearestQuarter(const TimeOfDay(hour: 10, minute: 59)).minute, 45);
    });

    test('preserves the hour', () {
      final result = roundToNearestQuarter(const TimeOfDay(hour: 14, minute: 37));
      expect(result.hour, 14);
      expect(result.minute, 30);
    });
  });

  group('getStartAndEndOfWeek', () {
    // Week: Sun Jan 5 – Sat Jan 11, 2025
    final sunday = DateTime(2025, 1, 5);
    final monday = DateTime(2025, 1, 6);
    final tuesday = DateTime(2025, 1, 7);
    final wednesday = DateTime(2025, 1, 8);
    final thursday = DateTime(2025, 1, 9);
    final friday = DateTime(2025, 1, 10);
    final saturday = DateTime(2025, 1, 11);

    for (final entry in {
      'Sunday': sunday,
      'Monday': monday,
      'Tuesday': tuesday,
      'Wednesday': wednesday,
      'Thursday': thursday,
      'Friday': friday,
      'Saturday': saturday,
    }.entries) {
      test('${entry.key} returns week Jan 5–11 2025', () {
        final (start, end) = getStartAndEndOfWeek(entry.value);
        expect(start, DateTime(2025, 1, 5, 0, 0, 0));
        expect(end, DateTime(2025, 1, 11, 23, 59, 59));
      });
    }

    test('start is midnight (00:00:00)', () {
      final (start, _) = getStartAndEndOfWeek(monday);
      expect(start.hour, 0);
      expect(start.minute, 0);
      expect(start.second, 0);
    });

    test('end is 23:59:59', () {
      final (_, end) = getStartAndEndOfWeek(monday);
      expect(end.hour, 23);
      expect(end.minute, 59);
      expect(end.second, 59);
    });
  });

  group('epochToDateTimeUtc / dateTimeToEpochUtc', () {
    test('epoch 0 is Jan 1 1970 UTC', () {
      final dt = epochToDateTimeUtc(0);
      expect(dt.year, 1970);
      expect(dt.month, 1);
      expect(dt.day, 1);
      expect(dt.isUtc, isTrue);
    });

    test('roundtrip preserves value', () {
      final original = DateTime.utc(2024, 6, 15, 10, 30);
      final epoch = dateTimeToEpochUtc(original);
      final recovered = epochToDateTimeUtc(epoch);
      expect(recovered.year, original.year);
      expect(recovered.month, original.month);
      expect(recovered.day, original.day);
      expect(recovered.hour, original.hour);
      expect(recovered.minute, original.minute);
    });
  });
}
