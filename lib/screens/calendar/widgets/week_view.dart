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

class CalendarWideView extends HookConsumerWidget {
  const CalendarWideView({
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
    return WeekView<Booking>(
      startHour: 6,
      startDay: WeekDays.sunday,
      minuteSlotSize: MinuteSlotSize.minutes60,
      hourIndicatorSettings: HourIndicatorSettings(),
      timeLineWidth: 80,
      headerStringBuilder: (date, {DateTime? secondaryDate}) =>
          '${prettyDateLocalFromEpoch(date.millisecondsSinceEpoch)}   |   ${prettyDateLocalFromEpoch(secondaryDate!.millisecondsSinceEpoch)}',
      headerStyle: HeaderStyle(
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
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
      weekDayBuilder: (date) {
        final dateString = _getWeekdayString(date);
        bool isToday = false;
        if (date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day) {
          isToday = true;
        }
        return Container(
          color: isToday ? AppColors.primaryGreen.withValues(alpha: 0.2) : Colors.transparent,
          alignment: Alignment.center,
          child: Text(
            (dateString),
            style: TextStyle(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? AppColors.primaryGreen : Colors.black,
            ),
          ),
        );
      },
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

_getWeekdayString(DateTime date) {
  switch (date.weekday) {
    case DateTime.monday:
      return 'Mon ${date.day}';
    case DateTime.tuesday:
      return 'Tue ${date.day}';
    case DateTime.wednesday:
      return 'Wed ${date.day}';
    case DateTime.thursday:
      return 'Thu ${date.day}';
    case DateTime.friday:
      return 'Fri ${date.day}';
    case DateTime.saturday:
      return 'Sat ${date.day}';
    case DateTime.sunday:
      return 'Sun ${date.day}';
  }
}
