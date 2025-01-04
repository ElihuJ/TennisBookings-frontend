import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'index.dart';

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

T? findByIdOrNull<T>(List<HasId> list, String? id) {
  final elementsFound = list.where((element) => element.id == id);
  if (elementsFound.isEmpty) {
    return null;
  } else {
    return elementsFound.first as T;
  }
}

Future wait(int milliseconds) {
  return Future.delayed(Duration(milliseconds: milliseconds));
}

delayPrepare(Function prepareFunction, {Duration duration = const Duration(milliseconds: 1)}) {
  Future.delayed(
    duration,
    () async {
      prepareFunction.call();
    },
  );
}

List<T> sortAlphabetically<T>(List<HasName> list) {
  final sortedList = list..sort((a, b) => a.name.compareTo(b.name));
  return sortedList as List<T>;
}

Color getContrastColor(Color color) {
  return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}
