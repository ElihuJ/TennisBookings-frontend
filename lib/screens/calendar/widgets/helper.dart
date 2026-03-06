import 'package:flutter/material.dart';

import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../global_widgets/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';

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
    showOnlyMembersModal(context: context, message: 'Only members can book in this club');
  } else if (isInThePast(date.millisecondsSinceEpoch)) {
    // ^ Booking in the past
    showGeneralForbiddenModal(context, title: 'Booking in the past', message: 'You cannot book a time in the past.');
  } else if (isAboveFutureLimit(date.millisecondsSinceEpoch)) {
    // ^ Booking too far in the future
    showGeneralForbiddenModal(context,
        title: 'Booking too far in the future', message: 'You cannot book a time more than 8 weeks in the future.');
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
