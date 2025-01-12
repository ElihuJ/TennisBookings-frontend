import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../global_types/index.dart';

int nowToEpochUtc() {
  return (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).round();
}

int dateTimeToEpochUtc(DateTime date) {
  final utcDate = date.toUtc();
  return (utcDate.millisecondsSinceEpoch / 1000).round();
}

DateTime epochToDateTimeUtc(int epoch) {
  final milliseconds = epoch * 1000;
  return DateTime.fromMillisecondsSinceEpoch(milliseconds).toUtc();
}

String prettyDateFromEpoch(int epoch) {
  final seconds = (epoch / 1000).round();
  final date = epochToDateTimeUtc(seconds);
  final utcDate = date.toUtc();
  final formattedDate = DateFormat('dd/MMM/yy').format(utcDate);
  return formattedDate.toString();
}

String getMonthAndYearFromEpoch(int epoch) {
  final seconds = (epoch / 1000).round();
  final date = epochToDateTimeUtc(seconds);
  final utcDate = date.toUtc();
  final formattedDate = DateFormat('MMM/yy').format(utcDate);
  return formattedDate.toString();
}

StartAndEndOfWeek getStartAndEndOfWeek(DateTime date) {
  final day = date.weekday;
  DateTime startDate;
  DateTime endDate;
  switch (day) {
    case DateTime.sunday:
      startDate = date;
      endDate = date.add(const Duration(days: 6));
      break;
    case DateTime.monday:
      startDate = date.subtract(Duration(days: 1));
      endDate = date.add(Duration(days: 5));
      break;
    case DateTime.tuesday:
      startDate = date.subtract(Duration(days: 2));
      endDate = date.add(Duration(days: 4));
      break;
    case DateTime.wednesday:
      startDate = date.subtract(Duration(days: 3));
      endDate = date.add(Duration(days: 3));
      break;
    case DateTime.thursday:
      startDate = date.subtract(Duration(days: 4));
      endDate = date.add(Duration(days: 2));
      break;
    case DateTime.friday:
      startDate = date.subtract(Duration(days: 5));
      endDate = date.add(Duration(days: 1));
      break;
    case DateTime.saturday:
      startDate = date.subtract(Duration(days: 6));
      endDate = date;
      break;
    default:
      startDate = date;
      endDate = date.add(const Duration(days: 6));
      break;
  }
  startDate = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
  endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
  return (startDate, endDate);
}

int localTimeOfDayToUTCEpoch(TimeOfDay time, DateTime date) {
  DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
  dateTime = dateTime.toUtc();
  return dateTimeToEpochUtc(dateTime);
}

int timeOfDayToEpochUtc(TimeOfDay time, DateTime date) {
  DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
  return dateTimeToEpochUtc(dateTime);
}

DateTime epochToLocalDateTime(int epoch) {
  final date = epochToDateTimeUtc(epoch);
  return date.toLocal();
}

bool validateTime({required int startTimeEpoch, required List<BookedTimeEpoch> bookedTimes, required DateTime date, required int endTimeEpoch}) {
  bool valid = true;

  for (final bookedTime in bookedTimes) {
    if (startTimeEpoch >= bookedTime.start && startTimeEpoch < bookedTime.end) {
      valid = false;
      break;
    }
    if (endTimeEpoch > bookedTime.start && endTimeEpoch <= bookedTime.end) {
      valid = false;
      break;
    }
    if (startTimeEpoch < bookedTime.start && endTimeEpoch > bookedTime.end) {
      valid = false;
      break;
    }
  }
  return valid;
}

TimeOfDay roundToNearestQuarter(TimeOfDay time) {
  final minutes = time.minute;
  int newMinutes = 0;
  if (minutes < 15) {
    newMinutes = 0;
  } else if (minutes < 30) {
    newMinutes = 15;
  } else if (minutes < 45) {
    newMinutes = 30;
  } else {
    newMinutes = 45;
  }
  return TimeOfDay(hour: time.hour, minute: newMinutes);
}
