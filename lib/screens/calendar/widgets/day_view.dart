import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../global_widgets/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';
import 'event_container.dart';

class CalendarMobileView extends HookConsumerWidget {
  const CalendarMobileView({
    super.key,
    required this.dateInView,
    required this.setDateInView,
    required this.eventController,
    required this.bookedTimes,
    required this.clubSelected,
    required this.courtSelected,
    required this.calendarKey,
  });

  final DateTime dateInView;
  final Function setDateInView;
  final EventController<Booking> eventController;
  final List<BookedTimeEpoch> bookedTimes;
  final Club clubSelected;
  final Court courtSelected;
  final GlobalKey calendarKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsNotifier = ref.read(clubsProvider.notifier);
    final user = ref.watch(userProvider);
    final onlyMembers = clubSelected.onlyMembers;
    final isUserMember = user.memberships.any((membership) => membership.clubId == clubSelected.id);
    return DayView<Booking>(
      startHour: 6,

      minuteSlotSize: MinuteSlotSize.minutes60,
      hourIndicatorSettings: HourIndicatorSettings(),
      timeLineWidth: 80,
      dateStringBuilder: (date, {secondaryDate}) => prettyDateLocalFromEpoch(date.millisecondsSinceEpoch),
      headerStyle: HeaderStyle(
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onDateTap: (date) {
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
      },
      controller: eventController,
      eventTileBuilder: (date, events, boundary, start, end) {
        return EventContainer(events: events, club: clubSelected);
      },
      showLiveTimeLineInAllDays: true, // * To display live time line in all pages in day view.
      initialDay: dateInView,
      key: calendarKey,
      heightPerMinute: 2, // * height occupied by 1 minute time span.
      showHalfHours: true,
      eventArranger: SideEventArranger(), // * To define how simultaneous events will be arranged.
      onPageChange: (startDate, number) async {
        setDateInView(startDate);
        clubsNotifier.loadBookings(clubSelected, courtSelected, startDate, user.uid);
      },
      endHour: 23, // * To set the end hour displayed
      keepScrollOffset: true, // * To maintain scroll offset when the page changes
    );
  }
}
