import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_helpers/bookings.dart';
import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';
import 'day_view.dart';
import 'loading_calendar.dart';
import 'week_view.dart';

const double _kHeightPerMinute = 2.0;
const double _kTimeLineWidth = 80.0;
const double _kLeftMargin = 20.0;
const double _kRightMargin = 20.0;
const double _kCalendarHeight = 700.0;
// Approximate header heights for each view (nav bar + optional day-labels row)
const double _kWeekHeaderHeight = 100.0;
const double _kDayHeaderHeight = 60.0;

class CalendarView extends StatefulHookConsumerWidget {
  const CalendarView({
    super.key,
    required this.clubSelected,
    required this.courtSelected,
    required this.dateInView,
    required this.setDateInView,
    required this.bookingIdSelected,
  });
  final Court courtSelected;
  final Club clubSelected;
  final DateTime dateInView;
  final Function setDateInView;
  final String? bookingIdSelected;

  @override
  ConsumerState<CalendarView> createState() => _CalendarView();
}

class _CalendarView extends ConsumerState<CalendarView> {
  List<Booking>? _bookings;

  bool functionDisabled = false;
  final _eventController = EventController<Booking>();
  final GlobalKey _calendarKey = GlobalKey();
  final _hoverNotifier = ValueNotifier<Offset?>(null);
  final _scrollNotifier = ValueNotifier<double>(0.0);

  @override
  void dispose() {
    _hoverNotifier.dispose();
    _scrollNotifier.dispose();
    super.dispose();
  }

  Widget? _buildHoverPreview(Offset position, double containerWidth, bool isMobile, double scrollOffset) {
    final double headerHeight = isMobile ? _kDayHeaderHeight : _kWeekHeaderHeight;

    // Convert viewport Y → content Y (accounts for scroll), snap to 1-hour boundary,
    // then convert back to viewport Y for positioning in the Stack.
    const double slotHeight = 60 * _kHeightPerMinute; // 120px per hour
    final double contentY = position.dy - headerHeight + scrollOffset;
    if (contentY < 0) return null;

    final double snappedContentY = (contentY / slotHeight).floor() * slotHeight;
    final double blockTop = snappedContentY - scrollOffset + headerHeight;

    if (blockTop < headerHeight) return null;
    if (blockTop + slotHeight > _kCalendarHeight) return null;

    double blockLeft;
    double blockWidth;

    if (isMobile) {
      blockLeft = _kLeftMargin + _kTimeLineWidth;
      blockWidth = containerWidth - _kLeftMargin - _kRightMargin - _kTimeLineWidth;
    } else {
      final double gridX = position.dx - _kLeftMargin - _kTimeLineWidth;
      if (gridX < 0) return null;
      final double availableWidth = containerWidth - _kLeftMargin - _kRightMargin - _kTimeLineWidth;
      if (availableWidth <= 0) return null;
      final double columnWidth = availableWidth / 7;
      final int dayIndex = (gridX / columnWidth).floor().clamp(0, 6);
      blockLeft = _kLeftMargin + _kTimeLineWidth + dayIndex * columnWidth;
      blockWidth = columnWidth;
    }

    return Positioned(
      top: blockTop,
      left: blockLeft,
      width: blockWidth,
      height: slotHeight,
      child: IgnorePointer(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.55),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clubsNotifier = ref.read(clubsProvider.notifier);
    final user = ref.watch(userProvider);

    final allEvents = [..._eventController.allEvents];
    final mobileView = isMobile(context);
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
        child: LayoutBuilder(
          builder: (ctx, constraints) => MouseRegion(
            cursor: SystemMouseCursors.contextMenu,
            onHover: (e) => _hoverNotifier.value = e.localPosition,
            onExit: (_) => _hoverNotifier.value = null,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
                  height: _kCalendarHeight,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.axis == Axis.vertical) {
                        _scrollNotifier.value = notification.metrics.pixels;
                      }
                      return false;
                    },
                    child: mobileView
                        ? CalendarMobileView(
                            dateInView: dateInView,
                            setDateInView: widget.setDateInView,
                            eventController: _eventController,
                            bookedTimes: bookedTimes,
                            clubSelected: widget.clubSelected,
                            courtSelected: widget.courtSelected,
                            calendarKey: _calendarKey,
                            bookingIdSelected: widget.bookingIdSelected,
                          )
                        : CalendarWideView(
                            dateInView: dateInView,
                            setDateInView: widget.setDateInView,
                            eventController: _eventController,
                            bookedTimes: bookedTimes,
                            clubSelected: widget.clubSelected,
                            courtSelected: widget.courtSelected,
                            calendarKey: _calendarKey,
                            bookingIdSelected: widget.bookingIdSelected,
                          ),
                  ),
                ),
                ListenableBuilder(
                  listenable: Listenable.merge([_hoverNotifier, _scrollNotifier]),
                  builder: (ctx, _) {
                    final position = _hoverNotifier.value;
                    if (position == null) return const SizedBox.shrink();
                    return _buildHoverPreview(position, constraints.maxWidth, mobileView, _scrollNotifier.value) ?? const SizedBox.shrink();
                  },
                ),
              ],
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
      final existingMergedBookings =
          existingBookingToMerge.mergedBookings.isEmpty ? [existingBookingToMerge] : existingBookingToMerge.mergedBookings;

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
        clubName: existingBookingToMerge.clubName,
        courtName: existingBookingToMerge.courtName,
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
