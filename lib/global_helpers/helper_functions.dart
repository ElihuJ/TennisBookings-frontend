import 'package:flutter/material.dart';

import 'index.dart';

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
