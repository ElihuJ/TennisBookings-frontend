import 'package:intl/intl.dart';

import '../global_types/index.dart';

int nowToEpochUtc() {
  final now = DateTime.now().toUtc();
  return fromDateToEpoch(now);
}

int getNowInEpoch() {
  return DateTime.now().millisecondsSinceEpoch;
}

int fromDateToEpoch(DateTime date) {
  return (date.millisecondsSinceEpoch / 1000).round();
}

DateTime fromEpochToDateTime(int epoch) {
  final milliseconds = epoch * 1000;
  return DateTime.fromMillisecondsSinceEpoch(milliseconds);
}

String prettyDateFromEpoch(int epoch) {
  final seconds = (epoch / 1000).round();
  final date = fromEpochToDateTime(seconds);
  final formattedDate = DateFormat('dd/MMM/yy').format(date);
  return formattedDate.toString();
}

String getMonthAndYearFromEpoch(int epoch) {
  final seconds = (epoch / 1000).round();
  final date = fromEpochToDateTime(seconds);
  final formattedDate = DateFormat('MMM/yy').format(date);
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
