import 'package:intl/intl.dart';

import 'index.dart';

int getNowInEpoch() {
  return DateTime.now().millisecondsSinceEpoch;
}

int fromDateToEpoch(DateTime date) {
  return date.millisecondsSinceEpoch;
}

DateTime fromEpochToDateTime(int epoch) {
  return DateTime.fromMillisecondsSinceEpoch(epoch);
}

String prettyDateFromEpoch(int epoch) {
  final date = fromEpochToDateTime(epoch);
  final formattedDate = DateFormat('dd/MMM/yy').format(date);
  return formattedDate.toString();
}

String getMonthAndYearFromEpoch(int epoch) {
  final date = fromEpochToDateTime(epoch);
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
