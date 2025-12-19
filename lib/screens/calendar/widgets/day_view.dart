import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';
import 'booking_container.dart';
import 'helper.dart';

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
    required this.bookingIdSelected,
  });

  final DateTime dateInView;
  final Function setDateInView;
  final EventController<Booking> eventController;
  final List<BookedTimeEpoch> bookedTimes;
  final Club clubSelected;
  final Court courtSelected;
  final GlobalKey calendarKey;
  final String? bookingIdSelected;

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
      backgroundColor: AppColors.almostWhite.withValues(alpha: 0.9),
      dateStringBuilder: (date, {secondaryDate}) => prettyDateLocalFromEpoch(date.millisecondsSinceEpoch),
      headerStyle: HeaderStyle(
        decoration: BoxDecoration(
          color: AppColors.primaryGreenTranslucent,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onDateTap: (date) {
        onDateTap(
          context: context,
          date: date,
          clubSelected: clubSelected,
          courtSelected: courtSelected,
          bookedTimes: bookedTimes,
          user: user,
          onlyMembers: onlyMembers,
          isUserMember: isUserMember,
        );
      },
      controller: eventController,
      eventTileBuilder: (date, events, boundary, start, end) {
        final openOnLoad = events.any((event) => event.event?.id == bookingIdSelected);
        return EventContainer(events: events, club: clubSelected, openModalOnLoad: openOnLoad);
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
