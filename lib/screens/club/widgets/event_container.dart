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
      bookingColor = AppColors.primaryGreen.withOpacity(0.5);
    }

    final computedTextColor = getContrastColor(bookingColor);

    return BookingContainer(
      user: user,
      event: events.first,
      bookingColor: bookingColor,
      computedTextColor: computedTextColor,
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
    required this.booking,
    required this.players,
    required this.club,
  });

  final User user;
  final CalendarEventData<Booking> event;
  final Color bookingColor;
  final Color computedTextColor;
  final Booking booking;
  final List<String> players;
  final Club club;

  @override
  Widget build(BuildContext context) {
    final bookingLengthEpoch = booking.to - booking.from;
    final bookingLessThanAnHour = bookingLengthEpoch < 3600;
    final fontSize = bookingLessThanAnHour ? 10.0 : 14.0;

    final allowsPublicBookings = club.allowPublicBookings;
    final isMemberOfClub = club.memberIds.contains(user.uid);

    final bookingAndUserContext =
        getBookingAndUserContext(booking: booking, user: user, allowsPublicBookings: allowsPublicBookings, isMemberOfClub: isMemberOfClub);
    final (mouseAction, isClickable) = getPermissionToClick(bookingAndUserContext: bookingAndUserContext);

    final targetBooking = booking.title == 'Merged booking';

    if (targetBooking) {
      booking.tbLogger('Merged booking found');
      mouseAction.tbLogger('Mouse action');
      isClickable.tbLogger('Is clickable');
    }

    return MouseRegion(
      cursor: mouseAction,
      onHover: (event) {},
      child: GestureDetector(
        onTap: () => onTapAction(
          booking: booking,
          user: user,
          bookingAndUserContext: bookingAndUserContext,
          context: context,
        ),
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

enum BookingAndUserContext { isNotLoggedIn, isNotAllowedToBook, isOwner, isParticipant, isMergedBooking, isAllowedToBook }

BookingAndUserContext getBookingAndUserContext(
    {required Booking booking, required User user, required bool allowsPublicBookings, required bool isMemberOfClub}) {
  if (user.uid.isEmpty) return BookingAndUserContext.isNotLoggedIn;
  if (!allowsPublicBookings && !isMemberOfClub) return BookingAndUserContext.isNotAllowedToBook;
  if (booking.ownerId == user.uid) return BookingAndUserContext.isOwner;
  if (booking.confirmedPlayerIds.contains(user.uid)) return BookingAndUserContext.isParticipant;
  if (allowsPublicBookings || isMemberOfClub) return BookingAndUserContext.isAllowedToBook;
  if (booking.format == BookingFormat.merged) return BookingAndUserContext.isMergedBooking;

  if (allowsPublicBookings) return BookingAndUserContext.isAllowedToBook;
  return BookingAndUserContext.isNotAllowedToBook;
}

(MouseCursor, bool) getPermissionToClick({required BookingAndUserContext bookingAndUserContext}) {
  switch (bookingAndUserContext) {
    case BookingAndUserContext.isNotLoggedIn || BookingAndUserContext.isNotAllowedToBook:
      return (SystemMouseCursors.forbidden, false);
    case BookingAndUserContext.isOwner || BookingAndUserContext.isMergedBooking || BookingAndUserContext.isParticipant:
      return (SystemMouseCursors.click, true);
    case BookingAndUserContext.isAllowedToBook:
      return (SystemMouseCursors.click, true);
  }
}

void onTapAction(
    {required Booking booking, required User user, required BookingAndUserContext bookingAndUserContext, required BuildContext context}) {
  if (bookingAndUserContext == BookingAndUserContext.isNotLoggedIn) {
    showLoginRegisterModal(context);
    return;
  }

  if (bookingAndUserContext == BookingAndUserContext.isNotAllowedToBook) {
    showOnlyMembersModal(context: context, message: 'Only members can view this booking');
    return;
  }
  if (bookingAndUserContext == BookingAndUserContext.isOwner) {
    showOwnerBookingDetailsModal(context: context, booking: booking);
    return;
  }

  if (bookingAndUserContext == BookingAndUserContext.isParticipant) {
    showParticipantBookingDetailsModal(context: context, booking: booking);
    return;
  }

  if (booking.format == BookingFormat.merged) {
    showMultipleBookingsModal(context: context, booking: booking);
    return;
  }

  if (bookingAndUserContext == BookingAndUserContext.isAllowedToBook) {
    showAllowedToBookModal(context: context, booking: booking);
    return;
  }
  return;
}
