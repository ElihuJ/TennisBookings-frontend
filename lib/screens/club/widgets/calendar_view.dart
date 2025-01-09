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
    final clubsNotifier = ref.read(clubsProvider.notifier);
    final allEvents = [..._eventController.allEvents];
    _eventController.removeAll(allEvents);

    _bookings = widget.courtSelected.publicBookings;

    // final dateInView = widget.dateInView;
    // ! TODO: MOCKED DATE
    final dateInView = DateTime(2025, 1, 1);

    // ^ ============================== Loading bookings  ==============================

    if (_bookings == null) {
      clubsNotifier.loadBookings(widget.clubSelected, widget.courtSelected, dateInView);
      _bookings = widget.courtSelected.publicBookings;
      return const CircularProgressIndicator();
    }

    List<CalendarEventData<Booking>> events = _bookings!.map((booking) {
      return CalendarEventData<Booking>(
        title: booking.title,
        titleStyle: const TextStyle(color: Colors.white),
        description: booking.format.name,
        startTime: epochToLocalDateTime(booking.from),
        endTime: epochToLocalDateTime(booking.to),
        color: Colors.red,
        date: epochToLocalDateTime(booking.from),
        event: booking,
      );
    }).toList();

    _eventController.addAll(events);
    final bookedTimes = getBookedTimes(_bookings!);

    return CalendarControllerProvider<Booking>(
      controller: _eventController,
      child: Expanded(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
          height: 500,
          child: WeekView<Booking>(
            startDay: WeekDays.sunday,
            minuteSlotSize: MinuteSlotSize.minutes60,
            hourIndicatorSettings: HourIndicatorSettings(),
            timeLineWidth: 80,
            headerStringBuilder: (date, {DateTime? secondaryDate}) =>
                '${prettyDateFromEpoch(date.millisecondsSinceEpoch)}   ---   ${prettyDateFromEpoch(secondaryDate!.millisecondsSinceEpoch)}',
            headerStyle: HeaderStyle(
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onDateTap: (date) => showCreateBookingModal(
                context: context, clubSelected: widget.clubSelected, courtSelected: widget.courtSelected, date: date, bookedTimes: bookedTimes),
            controller: _eventController,
            eventTileBuilder: (date, events, boundary, start, end) => EventContainer(events: events),
            showLiveTimeLineInAllDays: true, // To display live time line in all pages in day view.
            initialDay: dateInView,
            key: _calendarKey,
            heightPerMinute: 1, // height occupied by 1 minute time span.
            eventArranger: SideEventArranger(), // To define how simultaneous events will be arranged.
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

List<BookedTimeEpoch> getBookedTimes(List<Booking> bookings) {
  List<BookedTimeEpoch> bookedTimes = [];
  for (var booking in bookings) {
    if (booking.status == BookingStatus.confirmed) {
      bookedTimes.add(BookedTimeEpoch(booking.from, booking.to));
    }
  }
  return bookedTimes;
}
