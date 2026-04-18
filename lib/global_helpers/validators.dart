import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../config/config.dart';
import '../global_types/index.dart';
import '../strings/index.dart';

String? notEmptyStringValidator(String? value, BuildContext context) {
  if (value == null || value.isEmpty) {
    return context.localeString('');
  }
  if (value.length > 30) {
    return '${context.localeString('')} 30 ${context.localeString('')}';
  }
  return null;
}

String? utrValueValidator(String? value, BuildContext context) {
  if (value == null || value.isEmpty) {
    return null;
  }
  if (double.tryParse(value) == null) {
    return context.localeString(ValidatorStrings.invalidUtr);
  }
  if (double.parse(value) < Config.utrMinRating || double.parse(value) > Config.utrMaxRating) {
    return context.localeString(ValidatorStrings.invalidUtr);
  }

  return null;
}

String? validateNewTime({
  required int startDateEpoch,
  required int endDateEpoch,
  required List<BookedTimeEpoch> bookedTimes,
  required BuildContext context,
}) {
  String? validationError;
  if (endDateEpoch <= startDateEpoch) {
    validationError = context.localeString(ValidatorStrings.endAfterStart);
  }
  if ((endDateEpoch - startDateEpoch) > Config.maxBookingDuration) {
    validationError = context.localeString(ValidatorStrings.maxDuration).replaceAll('{hours}', Config.maxBookingHoursString.toString());
  }
  if ((endDateEpoch - startDateEpoch) < Config.minDuration) {
    validationError = context.localeString(ValidatorStrings.minDuration).replaceAll('{minutes}', Config.minDurationMinutesString.toString());
  }
  if (!validateTime(startTimeEpoch: startDateEpoch, bookedTimes: bookedTimes, endTimeEpoch: endDateEpoch)) {
    validationError = context.localeString(ValidatorStrings.timeBooked);
  }
  return validationError;
}

bool validateTime({required int startTimeEpoch, required List<BookedTimeEpoch> bookedTimes, required int endTimeEpoch}) {
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

String? validateUtrComparison({required String utrGt, required String utrLt, required BuildContext context}) {
  if (utrGt.isEmpty || utrLt.isEmpty) {
    return null;
  }
  final double? utrGtDouble = double.tryParse(utrGt);
  final double? utrLtDouble = double.tryParse(utrLt);

  if (utrGtDouble == null || utrLtDouble == null) {
    return context.localeString(ValidatorStrings.invalidUtr);
  }

  if (utrGtDouble > utrLtDouble) {
    return context.localeString(ValidatorStrings.utrComparison);
  }
  return null;
}
