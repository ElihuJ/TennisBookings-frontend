import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_helpers/index.dart';
import 'package:tennisbookings/screens/club/widgets/event_container.dart';
import 'package:tennisbookings/theme/index.dart';

import '../../../models/index.dart';
import '../../../state/index.dart';

class CalendarView extends StatefulHookConsumerWidget {
  const CalendarView({super.key, required this.clubSelected, required this.courtSelected, required this.dateInView, required this.setDateInView});
  final Court courtSelected;
  final Club clubSelected;
  final DateTime dateInView;
  final Function setDateInView;

  @override
  ConsumerState<CalendarView> createState() => _CalendarView();
}

class _CalendarView extends ConsumerState<CalendarView> {
  List<Booking>? _bookings;

  bool functionDisabled = false;
  final _eventController = EventController<Booking>();
  final GlobalKey _calendarKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userProvider).uid;
    final clubsNotifier = ref.read(clubsProvider.notifier);
    final allEvents = [..._eventController.allEvents];
    _eventController.removeAll(allEvents);

    _bookings = widget.courtSelected.publicBookings;

    // ^ ============================== Loading bookings  ==============================

    if (_bookings == null) {
      clubsNotifier.loadBookings(widget.clubSelected, widget.courtSelected, widget.dateInView);
      _bookings = widget.courtSelected.publicBookings;
      return const CircularProgressIndicator();
    }

    List<CalendarEventData<Booking>> events = _bookings!.map((booking) {
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

    final dateInView = widget.dateInView;

    return CalendarControllerProvider<Booking>(
      controller: _eventController,
      child: Expanded(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(40),
          height: 500,
          child: WeekView<Booking>(
            liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
              color: AppColors.primaryGreen,
              showTime: true,
            ),
            startDay: WeekDays.sunday,
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
            initialDay: dateInView,
            key: _calendarKey,
            heightPerMinute: 1, // height occupied by 1 minute time span.
            eventArranger: SideEventArranger(), // To define how simultaneous events will be arranged.
            onEventTap: (events, date) {
              if (events.first.event!.ownerId == userId) {
                showDialog(context: context, builder: (context) => AlertDialog(content: Text('You are the owner')));
              }
            },
            onPageChange: (startDate, number) async {
              widget.setDateInView(startDate);
              clubsNotifier.loadBookings(widget.clubSelected, widget.courtSelected, startDate);
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
