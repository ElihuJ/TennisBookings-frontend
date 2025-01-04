import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_helpers/index.dart';
import 'package:tennisbookings/screens/club/widgets/event_container.dart';
import 'package:tennisbookings/theme/index.dart';

import '../../../models/index.dart';
import '../../../state/index.dart';

class CalendarView extends HookConsumerWidget {
  CalendarView({
    super.key,
    required List<Booking> bookings,
  }) : _bookings = bookings;

  final List<Booking> _bookings;

  DateTime get now => DateTime.now();
  DateTime get aYearAgo => now.subtract(const Duration(days: 365));
  DateTime get nowNextYear => now.add(const Duration(days: 365));
  final _eventController = EventController<Booking>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userProvider).uid;

    List<CalendarEventData<Booking>> events = _bookings.map((booking) {
      return CalendarEventData<Booking>(
        title: booking.title,
        titleStyle: const TextStyle(color: Colors.white),
        description: booking.format.name,
        startTime: fromEpochToDateTime(booking.from),
        endTime: fromEpochToDateTime(booking.to),
        color: Colors.red,
        date: fromEpochToDateTime(booking.from),
        event: booking,
      );
    }).toList();

    _eventController.addAll(events);

    return CalendarControllerProvider<Booking>(
      controller: _eventController,
      child: Expanded(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(40),
          height: 500,
          child: WeekView<Booking>(
            minuteSlotSize: MinuteSlotSize.minutes60,
            hourIndicatorSettings: HourIndicatorSettings(),
            timeLineWidth: 80,
            headerStringBuilder: (date, {DateTime? secondaryDate}) =>
                '${prettyDateFromEpoch(date.millisecondsSinceEpoch)} - ${prettyDateFromEpoch(secondaryDate!.millisecondsSinceEpoch)}',
            headerStyle: HeaderStyle(
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            controller: _eventController,
            eventTileBuilder: (date, events, boundary, start, end) => EventContainer(events: events),
            showLiveTimeLineInAllDays: true, // To display live time line in all pages in day view.
            minDay: aYearAgo,
            maxDay: nowNextYear,
            initialDay: now,
            heightPerMinute: 1, // height occupied by 1 minute time span.
            eventArranger: SideEventArranger(), // To define how simultaneous events will be arranged.
            onEventTap: (events, date) {
              if (events.first.event!.ownerId == userId) {
                showDialog(context: context, builder: (context) => AlertDialog(content: Text('You are the owner')));
              }
            },
            // startHour: 4, // To set the first hour displayed (ex: 05:00)
            // endHour: 23, // To set the end hour displayed
            keepScrollOffset: true, // To maintain scroll offset when the page changes
          ),
        ),
      ),
    );
  }
}
