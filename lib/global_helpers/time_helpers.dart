import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../global_types/index.dart';

// * ============== GETTING CURRENT DATE AND TIME ==============

int nowToEpochUtc() {
  return DateTime.now().toUtc().millisecondsSinceEpoch;
}

int dateTimeToEpochUtc(DateTime date) {
  final utcDate = date.toUtc();
  return (utcDate.millisecondsSinceEpoch).round();
}

DateTime epochToDateTimeUtc(int epoch) => DateTime.fromMillisecondsSinceEpoch(epoch).toUtc();

// * ============== GETTING DATE AS STRING ==============

String prettyDateUtcFromEpoch(int milliseconds) {
  final date = epochToDateTimeUtc(milliseconds);
  final utcDate = date.toUtc();
  final formattedDate = DateFormat('dd/MMM/yy').format(utcDate);
  return formattedDate.toString();
}

String prettyDateLocalFromEpoch(int milliseconds) {
  final date = epochToDateTimeUtc(milliseconds);
  final localDate = date.toLocal();
  final formattedDate = DateFormat('dd/MMM/yy').format(localDate);
  return formattedDate.toString();
}

String prettyDateLocalWithTimeFromEpoch(int milliseconds) {
  final date = epochToDateTimeUtc(milliseconds);
  final localDate = date.toLocal();
  final formattedDate = DateFormat('dd/MMM/yy HH:mm').format(localDate);
  return formattedDate.toString();
}

// * ============== GETTING TIME AS STRING ==============

String getUtcTimeFromEpoch(int milliseconds) {
  final date = epochToDateTimeUtc(milliseconds);
  final utcDate = date.toUtc();
  final formattedDate = DateFormat('HH:mm').format(utcDate);
  return formattedDate.toString();
}

String getLocalTimeFromEpoch(int milliseconds) {
  final date = epochToDateTimeUtc(milliseconds);
  final utcDate = date.toLocal();
  final formattedDate = DateFormat('HH:mm').format(utcDate);
  return formattedDate.toString();
}

int timeOfDayToEpochUtc(TimeOfDay time, DateTime date) {
  DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
  return dateTimeToEpochUtc(dateTime);
}

DateTime epochSecondsToLocalDateTime(int milliseconds) {
  final date = epochToDateTimeUtc(milliseconds);
  return date.toLocal();
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

// * ============== CALCULATING STARTS AND END OF WEEK ==============

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
