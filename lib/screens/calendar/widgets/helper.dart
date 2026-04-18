import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../global_widgets/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../strings/index.dart';

void onDateTap(
    {required BuildContext context,
    required DateTime date,
    required Club clubSelected,
    required Court courtSelected,
    required List<BookedTimeEpoch> bookedTimes,
    required User user,
    required bool onlyMembers,
    required bool isUserMember}) {
  if (user.uid.isEmpty) {
    // ^ User is not logged in
    showLoginRegisterModal(context);
  } else if (onlyMembers && !isUserMember) {
    // ^ User is not a member
    showOnlyMembersModal(context: context, message: context.localeString(CalendarStrings.onlyMembersMessage));
  } else if (isInThePast(date.millisecondsSinceEpoch)) {
    // ^ Booking in the past
    showGeneralForbiddenModal(context,
        title: context.localeString(CalendarStrings.bookingPastTitle),
        message: context.localeString(CalendarStrings.bookingPastMessage));
  } else if (isAboveFutureLimit(date.millisecondsSinceEpoch)) {
    // ^ Booking too far in the future
    showGeneralForbiddenModal(context,
        title: context.localeString(CalendarStrings.bookingFutureTitle),
        message: context.localeString(CalendarStrings.bookingFutureMessage));
  } else if (!onlyMembers && !isUserMember) {
    // ^ User is not a member and can book
    showCreateCasualBookingModal(
        context: context, clubSelected: clubSelected, courtSelected: courtSelected, date: date, bookedTimes: bookedTimes);
  } else {
    // ^ User is member in and can book
    showCreateMemberBookingModal(
        context: context, clubSelected: clubSelected, courtSelected: courtSelected, date: date, bookedTimes: bookedTimes);
  }
}
