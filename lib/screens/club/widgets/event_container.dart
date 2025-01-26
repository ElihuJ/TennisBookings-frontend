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
  const EventContainer({super.key, required this.events, required this.club});

  final List<CalendarEventData<Booking>> events;
  final Club club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    final booking = events.first.event!;
    final players = booking.confirmedPlayerIds;
    final isBooked = booking.status == BookingStatus.confirmed;
    final owned = booking.ownerId == user.uid;

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
      bookingColor: bookingColor,
      computedTextColor: computedTextColor,
      fontSize: fontSize,
      booking: booking,
      players: players,
      club: club,
    );
  }
}

class BookingContainer extends StatelessWidget {
  const BookingContainer({
    super.key,
    required this.user,
    required this.event,
    required this.bookingColor,
    required this.computedTextColor,
    required this.fontSize,
    required this.booking,
    required this.players,
    required this.club,
  });

  final User user;
  final CalendarEventData<Booking> event;
  final Color bookingColor;
  final Color computedTextColor;
  final double fontSize;
  final Booking booking;
  final List<String> players;
  final Club club;

  @override
  Widget build(BuildContext context) {
    final allowsPublicBookings = club.allowPublicBookings;
    final isUserMember = club.memberIds.contains(user.uid);
    final (mouseAction, isClickable) = getPermissionToClick(booking, user, allowsPublicBookings, isUserMember);

    return MouseRegion(
      cursor: mouseAction,
      onHover: (event) {},
      child: GestureDetector(
        onTap: () => onTapAction(booking, user, isClickable, isClickable, context),
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

(MouseCursor, bool) getPermissionToClick(Booking booking, User user, bool allowsPublicBookings, bool isUserMember) {
  if (user.uid.isEmpty) return (SystemMouseCursors.forbidden, false);
  if (!allowsPublicBookings && !isUserMember) return (SystemMouseCursors.forbidden, false);
  if (booking.ownerId == user.uid) return (SystemMouseCursors.click, true);
  return (SystemMouseCursors.basic, false);
}

void onTapAction(Booking booking, User user, bool allowsPublicBookings, bool isUserMember, BuildContext context) {
  if (user.uid.isEmpty) {
    showLoginRegisterModal(context);
    return;
  }

  if (!allowsPublicBookings && !isUserMember) {
    showOnlyMembersModal(context: context, message: 'Only members can view this booking');
    return;
  }
  if (booking.ownerId == user.uid) return;
  return;
}
