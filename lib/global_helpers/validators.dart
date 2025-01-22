import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../config/config.dart';
import '../global_types/index.dart';
import 'index.dart';

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
    return 'Required field';
  }
  if (double.tryParse(value) == null) {
    return '${Config.utrMinRating}-${Config.utrMaxRating}';
  }
  if (double.parse(value) < Config.utrMinRating || double.parse(value) > Config.utrMaxRating) {
    return '${Config.utrMinRating}-${Config.utrMaxRating}';
  }
  return null;
}

String? validateNewTime(
    {required int startDateEpoch, required int endDateEpoch, required List<BookedTimeEpoch> bookedTimes, required DateTime date}) {
  String? validationError;
  if (endDateEpoch <= startDateEpoch) {
    validationError = 'End time must be after start time';
  }
  if ((endDateEpoch - startDateEpoch) > Config.maxBookingDuration) {
    validationError = 'Max duration per booking is ${Config.maxBookingHours} hour';
  }

  if ((endDateEpoch - startDateEpoch) < Config.minDuration) {
    validationError = 'Min duration per booking is ${Config.minDurationMinutes} minutes';
  }
  if (!validateTime(startTimeEpoch: startDateEpoch, bookedTimes: bookedTimes, date: date, endTimeEpoch: endDateEpoch)) {
    validationError = 'Time slot is already booked';
  }
  return validationError;
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

String? validateUtrComparison({required String utrGt, required String utrLt, required BuildContext context}) {
  if (utrGt.isEmpty || utrLt.isEmpty) {
    return 'Required field';
  }
  final double? utrGtDouble = double.tryParse(utrGt);
  final double? utrLtDouble = double.tryParse(utrLt);

  if (utrGtDouble == null || utrLtDouble == null) {
    return 'Invalid UTR';
  }

  if (utrGtDouble > utrLtDouble) {
    return 'UTR must be greater than or equal to Lower Limit';
  }
  return null;
}
