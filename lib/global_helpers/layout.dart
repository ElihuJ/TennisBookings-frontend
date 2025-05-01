import 'dart:math';

import 'package:flutter/widgets.dart';

double widthPercent(BuildContext context, {required double percentage}) {
  return MediaQuery.of(context).size.width * (percentage / 100);
}

double heightPercent(BuildContext context, {required double percentage}) {
  return MediaQuery.of(context).size.height * (percentage / 100);
}

double scaleText(BuildContext context, {double maxTextScaleFactor = 3}) {
  final width = MediaQuery.of(context).size.width;
  double val = (width / 1400) * maxTextScaleFactor;
  return max(1, min(val, maxTextScaleFactor));
}

bool isMobile(BuildContext context) {
  return MediaQuery.of(context).size.width < 600;
}
