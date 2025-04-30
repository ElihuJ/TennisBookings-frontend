import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_helpers/bookings.dart';
import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../global_widgets/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';
import 'event_container.dart';
import 'loading_calendar.dart';

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
    final user = ref.watch(userProvider);
    final allowsPublicBookings = widget.clubSelected.allowPublicBookings;
    final isUserMember = user.memberships.any((membership) => membership.clubId == widget.clubSelected.id);
    final allEvents = [..._eventController.allEvents];
    _eventController.removeAll(allEvents);

    _bookings = widget.courtSelected.publicBookings;
    if (widget.courtSelected.privateBookings != null) {
      final privateBookings = widget.courtSelected.privateBookings!;
      _bookings = replacePublicForPrivate(_bookings!, privateBookings);
    }

    final dateInView = widget.dateInView;
    // ^ ============================== Loading bookings when accessing page directly ==============================

    if (_bookings == null) {
      clubsNotifier.loadBookings(widget.clubSelected, widget.courtSelected, dateInView, user.uid);
      return LoadingCalendarView(dateInView: dateInView);
    }

    if (user.uid.isNotEmpty && widget.courtSelected.privateBookings == null) {
      clubsNotifier.loadBookings(widget.clubSelected, widget.courtSelected, dateInView, user.uid);
      return LoadingCalendarView(dateInView: dateInView);
    }

    final filteredBookings = filterRestrictedBookings(bookings: _bookings!, user: user);
    List<Booking> mergedBookings = mergeConflictedBookings(bookings: filteredBookings, user: user);

    List<CalendarEventData<Booking>> events = mergedBookings.map((booking) {
      return CalendarEventData<Booking>(
        title: booking.title,
        titleStyle: const TextStyle(color: Colors.white),
        description: booking.format.name,
        startTime: epochSecondsToLocalDateTime(booking.startTime),
        endTime: epochSecondsToLocalDateTime(booking.endTime),
        color: Colors.red,
        date: epochSecondsToLocalDateTime(booking.startTime),
        event: booking,
      );
    }).toList();

    _eventController.addAll(events);
    final bookedTimes = getConfirmedBookedTimes(_bookings!);

    return CalendarControllerProvider<Booking>(
      controller: _eventController,
      child: Expanded(
        child: MouseRegion(
          cursor: SystemMouseCursors.contextMenu,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
            height: 700,
            child: WeekView<Booking>(
              startHour: 6,
              startDay: WeekDays.sunday,
              minuteSlotSize: MinuteSlotSize.minutes60,
              hourIndicatorSettings: HourIndicatorSettings(),
              timeLineWidth: 80,
              headerStringBuilder: (date, {DateTime? secondaryDate}) =>
                  '${prettyDateUtcFromEpoch(date.millisecondsSinceEpoch)}   ---   ${prettyDateUtcFromEpoch(secondaryDate!.millisecondsSinceEpoch)}',
              headerStyle: HeaderStyle(
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onDateTap: (date) {
                if (user.uid.isEmpty) {
                  showLoginRegisterModal(context);
                  return;
                }
                if (!allowsPublicBookings && !isUserMember) {
                  showOnlyMembersModal(context: context, message: 'Only members can book in this club');
                  return;
                }
                if (isInThePast(date.millisecondsSinceEpoch)) {
                  showGeneralForbiddenModal(context, title: 'Booking in the past', message: 'You cannot book a time in the past.');
                  return;
                }

                if (isAboveFutureLimit(date.millisecondsSinceEpoch)) {
                  showGeneralForbiddenModal(context,
                      title: 'Booking too far in the future', message: 'You cannot book a time more than 8 weeks in the future.');
                  return;
                }

                showCreateBookingModal(
                    context: context, clubSelected: widget.clubSelected, courtSelected: widget.courtSelected, date: date, bookedTimes: bookedTimes);
              },
              controller: _eventController,
              eventTileBuilder: (date, events, boundary, start, end) {
                return EventContainer(events: events, club: widget.clubSelected);
              },
              showLiveTimeLineInAllDays: true, // To display live time line in all pages in day view.
              initialDay: dateInView,
              key: _calendarKey,
              heightPerMinute: 2, // height occupied by 1 minute time span.
              showHalfHours: true,
              eventArranger: SideEventArranger(), // To define how simultaneous events will be arranged.
              onPageChange: (startDate, number) async {
                widget.setDateInView(startDate);
                clubsNotifier.loadBookings(widget.clubSelected, widget.courtSelected, startDate, user.uid);
              },
              endHour: 23, // To set the end hour displayed
              keepScrollOffset: true, // To maintain scroll offset when the page changes
            ),
          ),
        ),
      ),
    );
  }
}

List<BookedTimeEpoch> getConfirmedBookedTimes(List<Booking> bookings) {
  List<BookedTimeEpoch> bookedTimes = [];
  for (var booking in bookings) {
    if (booking.status == BookingStatus.confirmed) {
      bookedTimes.add(BookedTimeEpoch(booking.startTime, booking.endTime));
    }
  }
  return bookedTimes;
}

List<Booking> replacePublicForPrivate(List<Booking> publicBookings, List<Booking> privateBookings) {
  final consolidatedBookings = [...publicBookings];
  for (final privateBooking in privateBookings) {
    final bookingToReplace = findByIdOrNull<Booking>(publicBookings, privateBooking.id);
    if (bookingToReplace != null) {
      final index = publicBookings.indexOf(bookingToReplace);
      consolidatedBookings[index] = privateBooking;
    }
  }

  return consolidatedBookings;
}

Booking? checkForConflict({required List<Booking> mergedBookings, required Booking bookingToCompare}) {
  Booking? existingBookingToMerge;
  for (final existingBooking in mergedBookings) {
    if (bookingToCompare.startTime >= existingBooking.startTime && bookingToCompare.startTime < existingBooking.endTime) {
      existingBookingToMerge = existingBooking;
      break;
    }
    if (bookingToCompare.endTime > existingBooking.startTime && bookingToCompare.endTime <= existingBooking.endTime) {
      existingBookingToMerge = existingBooking;
      break;
    }
    if (bookingToCompare.startTime < existingBooking.startTime && bookingToCompare.endTime > existingBooking.endTime) {
      existingBookingToMerge = existingBooking;
      break;
    }
  }
  return existingBookingToMerge;
}

int getEarliestStart(Booking booking1, Booking booking2) {
  return booking1.startTime < booking2.startTime ? booking1.startTime : booking2.startTime;
}

int getLatestEnd(Booking booking1, Booking booking2) {
  return booking1.endTime > booking2.endTime ? booking1.endTime : booking2.endTime;
}

List<Booking> mergeConflictedBookings({required List<Booking> bookings, required User user}) {
  final mergedBookings = <Booking>[];

  for (final booking in bookings) {
    final existingBookingToMerge = checkForConflict(mergedBookings: mergedBookings, bookingToCompare: booking);
    if (existingBookingToMerge != null) {
      final earliestStart = getEarliestStart(existingBookingToMerge, booking);
      final latestEnd = getLatestEnd(existingBookingToMerge, booking);
      final existingMergedBookings = existingBookingToMerge.mergedBookings.isEmpty ? [existingBookingToMerge] : existingBookingToMerge.mergedBookings;

      final mergedBooking = Booking(
        id: existingBookingToMerge.id,
        startTime: earliestStart,
        endTime: latestEnd,
        title: 'Multiple Options (Click for more details)',
        ownerId: '',
        status: BookingStatus.open,
        confirmedPlayerIds: [],
        format: BookingFormat.merged,
        courtId: existingBookingToMerge.courtId,
        private: false,
        requests: [],
        mergedBookings: [...existingMergedBookings, booking],
        clubId: existingBookingToMerge.clubId,
      );
      mergedBookings.removeWhere((element) => element.id == existingBookingToMerge.id);
      mergedBookings.add(mergedBooking);
      continue;
    }
    mergedBookings.add(booking);
  }

  return mergedBookings;
}
