import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:tennisbookings/global_helpers/index.dart';
import 'package:tennisbookings/screens/club/widgets/event_container.dart';
import 'package:tennisbookings/theme/index.dart';

import '../../../global_widgets/containers/bordered_box.dart';
import '../../../models/index.dart';

class CalendarView extends StatelessWidget {
  CalendarView({
    super.key,
    required List<Booking> bookings,
  }) : _bookings = bookings;

  final List<Booking> _bookings;

  DateTime get now => DateTime.now();
  final _eventController = EventController<Booking?>();

  @override
  Widget build(BuildContext context) {
    List<CalendarEventData<Booking>> events = _bookings.map((booking) {
      final date = fromEpochToDateTime(booking.from);
      date.tbLogger('DATE');
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

    return CalendarControllerProvider<Booking?>(
      controller: _eventController,
      child: Expanded(
        child: BorderedBox(
          width: double.infinity,
          margin: const EdgeInsets.all(40),
          height: 500,
          child: WeekView<Booking?>(
            headerStringBuilder: (date, {DateTime? secondaryDate}) {
              return '${prettyDateFromEpoch(date.millisecondsSinceEpoch)} - ${prettyDateFromEpoch(secondaryDate!.millisecondsSinceEpoch)}';
            },
            headerStyle: HeaderStyle(
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            controller: _eventController,
            eventTileBuilder: (date, events, boundry, start, end) {
              events.tbLogger('EVENT!!');
              // Return your widget to display as event tile.
              return EventContainer(events: events);
            },
            showLiveTimeLineInAllDays: true, // To display live time line in all pages in day view.
            minDay: DateTime(1990),
            maxDay: DateTime(2050),
            initialDay: DateTime(2025),
            heightPerMinute: 1, // height occupied by 1 minute time span.
            eventArranger: SideEventArranger(), // To define how simultaneous events will be arranged.
            onEventTap: (events, date) {
              showDialog(context: context, builder: (context) => AlertDialog(content: Text(events.first.title)));
            },
            onEventDoubleTap: (events, date) => print(events),
            onEventLongTap: (events, date) => print(events),
            onDateLongPress: (date) => print(date),
            // startHour: 5, // To set the first hour displayed (ex: 05:00)
            // endHour: 20, // To set the end hour displayed
            keepScrollOffset: true, // To maintain scroll offset when the page changes
          ),
        ),
      ),
    );
  }
}
