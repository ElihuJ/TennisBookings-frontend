import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../global_widgets/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';

class EventContainer extends HookConsumerWidget {
  const EventContainer({
    super.key,
    required this.events,
  });

  final List<CalendarEventData<Booking>> events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    final booking = events.first.event!;
    final players = booking.confirmedPlayerIds;
    final isBooked = booking.status == BookingStatus.confirmed;
    final owned = booking.ownerId == user.uid;
    final isClickable = owned || !isBooked;

    // * Computing colours
    Color bookingColor = owned ? AppColors.primaryGreen : AppColors.darkGreen;
    if (!isBooked) {
      // if (true) {
      bookingColor = AppColors.primaryGreen.withOpacity(0.5);
    }

    final bookingLengthEpoch = booking.to - booking.from;

    final bookingLessThanAnHour = bookingLengthEpoch < 3600;

    final computedTextColor = getContrastColor(bookingColor);
    final fontSize = bookingLessThanAnHour ? 10.0 : 14.0;

    return BookingContainer(
        user: user,
        event: events.first,
        isClickable: isClickable,
        bookingColor: bookingColor,
        computedTextColor: computedTextColor,
        fontSize: fontSize,
        booking: booking,
        players: players);
  }
}

class BookingContainer extends StatelessWidget {
  const BookingContainer({
    super.key,
    required this.user,
    required this.event,
    required this.isClickable,
    required this.bookingColor,
    required this.computedTextColor,
    required this.fontSize,
    required this.booking,
    required this.players,
  });

  final User user;
  final CalendarEventData<Booking> event;
  final bool isClickable;
  final Color bookingColor;
  final Color computedTextColor;
  final double fontSize;
  final Booking booking;
  final List<String> players;

  @override
  Widget build(BuildContext context) {
    final isMerged = event.event!.mergedBookings.isNotEmpty;

    if (isMerged) {
      final mergedEvent = event.event!;
      mergedEvent.mergedBookings.tbLogger('mergedEvent.mergedBookings');
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (event) {},
      child: GestureDetector(
        onTap: () {
          if (user.uid.isEmpty) {
            showLoginRegisterModal(context);
            return;
          }
          if (event.event!.ownerId == user.uid) {
            showDialog(context: context, builder: (context) => AlertDialog(content: Text('You are the owner')));
            return;
          }
          if (isClickable) {
            showDialog(context: context, builder: (context) => AlertDialog(content: Text('You can\'t book this event')));
            return;
          }
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: bookingColor,
            border: Border.all(
              color: Colors.black,
              style: BorderStyle.solid,
            ),
          ),
          height: 100,
          width: 100,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrettyText(
                  '${event.title}\n${event.description}',
                  style: TextStyle(color: computedTextColor, fontSize: fontSize),
                  textAlign: TextAlign.left,
                ),
                PrettyText('(${booking.format.name})', style: TextStyle(color: computedTextColor, fontSize: fontSize), textAlign: TextAlign.left),
                SizedBox(height: 20),
                for (final _ in players)
                  CircleAvatar(
                    backgroundColor: AppColors.backgroundGreen,
                    child: Icon(
                      Icons.person,
                      color: AppColors.primaryGreen,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
