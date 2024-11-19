import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../config/config.dart';
import '../types/index.dart';

var logger = Logger();

final config = Config();

enum DebugLevel { trace, debug, info, warning, error, fatal }

extension Log on Object {
  void log([String? title, DebugLevel debugLevel = DebugLevel.debug]) {
    String myLog = '===============  ';
    myLog += title != null ? title.toUpperCase() : 'DEBUG';
    myLog += '  ===============\n';
    myLog += toString();
    if (config.environment != Environment.prod && kDebugMode) {
      switch (debugLevel) {
        case DebugLevel.trace:
          logger.t(myLog);
          break;
        case DebugLevel.debug:
          logger.d(myLog);
          break;
        case DebugLevel.info:
          logger.i(myLog);
          break;
        case DebugLevel.warning:
          logger.w(myLog);
          break;
        case DebugLevel.error:
          logger.e(myLog);
          break;
        case DebugLevel.fatal:
          logger.f(myLog);
          break;
      }
    }
  }
}
