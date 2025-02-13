import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../global_widgets/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';
import 'index.dart';

class EventContainer extends HookConsumerWidget {
  const EventContainer({super.key, required this.events, required this.club});

  final List<CalendarEventData<Booking>> events;
  final Club club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    final booking = events.first.event!;
    final confirmedPlayerIds = booking.confirmedPlayerIds;
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
      confirmedPlayerIds: confirmedPlayerIds,
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
    required this.confirmedPlayerIds,
    required this.club,
  });

  final User user;
  final CalendarEventData<Booking> event;
  final Color bookingColor;
  final Color computedTextColor;
  final Booking booking;
  final List<String> confirmedPlayerIds;
  final Club club;

  @override
  Widget build(BuildContext context) {
    final bookingLengthEpoch = booking.to - booking.from;
    final bookingLessThanAnHour = bookingLengthEpoch < 3600;
    final fontSize = bookingLessThanAnHour ? 10.0 : 14.0;

    final allowsPublicBookings = club.allowPublicBookings;
    final isMemberOfClub = club.memberIds.contains(user.uid);

    final bookingAndUserContext =
        _getBookingAndUserContext(booking: booking, user: user, allowsPublicBookings: allowsPublicBookings, isMemberOfClub: isMemberOfClub);
    final (mouseAction, isClickable) = _getPermissionToClick(bookingAndUserContext: bookingAndUserContext);

    return MouseRegion(
      cursor: mouseAction,
      onHover: (event) {},
      child: GestureDetector(
        onTap: () => _onTapAction(
          booking: booking,
          user: user,
          bookingAndUserContext: bookingAndUserContext,
          context: context,
          clubId: club.id,
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
                PlayerIcons(
                  confirmedPlayerIds: confirmedPlayerIds,
                  booking: booking,
                  clubId: club.id,
                  type: PlayerIconsType.row,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

BookingAndUserContext _getBookingAndUserContext(
    {required Booking booking, required User user, required bool allowsPublicBookings, required bool isMemberOfClub}) {
  final clubIsPublicOrMemberOfClub = allowsPublicBookings || isMemberOfClub;

  if (user.uid.isEmpty) return BookingAndUserContext.isNotLoggedIn;
  if (!allowsPublicBookings && !isMemberOfClub) return BookingAndUserContext.isNotAllowedToBook;
  if (booking.ownerId == user.uid) return BookingAndUserContext.isOwner;
  if (booking.confirmedPlayerIds.contains(user.uid)) return BookingAndUserContext.isParticipant;
  if (booking.format == BookingFormat.merged) return BookingAndUserContext.isMergedBooking; // * This needs to come before open bookings
  if (clubIsPublicOrMemberOfClub && booking.status == BookingStatus.open) return BookingAndUserContext.isOpenForInvites;
  if (booking.status == BookingStatus.confirmed && booking.ownerId != user.uid && booking.private) return BookingAndUserContext.isNotMineAndPrivate;
  if (booking.status == BookingStatus.confirmed && booking.ownerId != user.uid && !booking.private) return BookingAndUserContext.isNotMineAndPublic;

  if (allowsPublicBookings) return BookingAndUserContext.isOpenForInvites;
  return BookingAndUserContext.isNotAllowedToBook;
}

typedef CanClick = bool;

(MouseCursor, CanClick) _getPermissionToClick({required BookingAndUserContext bookingAndUserContext}) {
  switch (bookingAndUserContext) {
    case BookingAndUserContext.isNotLoggedIn || BookingAndUserContext.isNotAllowedToBook:
      return (SystemMouseCursors.forbidden, false);
    case BookingAndUserContext.isOwner || BookingAndUserContext.isMergedBooking || BookingAndUserContext.isParticipant:
      return (SystemMouseCursors.click, true);
    case BookingAndUserContext.isOpenForInvites:
      return (SystemMouseCursors.click, true);
    case BookingAndUserContext.isNotMineAndPublic:
      return (SystemMouseCursors.click, true);
    case BookingAndUserContext.isNotMineAndPrivate:
      return (SystemMouseCursors.forbidden, false);
  }
}

void _onTapAction({
  required Booking booking,
  required User user,
  required BookingAndUserContext bookingAndUserContext,
  required String clubId,
  required BuildContext context,
}) {
  final notAllowedToBook =
      bookingAndUserContext == BookingAndUserContext.isNotLoggedIn || bookingAndUserContext == BookingAndUserContext.isNotAllowedToBook;

  if (bookingAndUserContext == BookingAndUserContext.isNotLoggedIn) {
    showLoginRegisterModal(context);
    return;
  }

  if (notAllowedToBook && !booking.private) {
    showOnlyMembersModal(context: context);
    return;
  }

  if (bookingAndUserContext == BookingAndUserContext.isNotMineAndPrivate) {
    showPrivateWallModal(context: context);
    return;
  }
  if (bookingAndUserContext == BookingAndUserContext.isOwner ||
      bookingAndUserContext == BookingAndUserContext.isParticipant ||
      bookingAndUserContext == BookingAndUserContext.isOpenForInvites ||
      bookingAndUserContext == BookingAndUserContext.isNotMineAndPublic) {
    final bookingDetailsType = getBookingDetailsType(bookingAndUserContext);
    showBookingDetailsModal(context: context, booking: booking, clubId: clubId, bookingDetailsType: bookingDetailsType);
    return;
  }

  // if (bookingAndUserContext == _BookingAndUserContext.isParticipant) {
  //   showParticipantBookingDetailsModal(context: context, booking: booking, clubId: clubId, type: PlayerIconsType.column);
  //   return;
  // }

  // if (bookingAndUserContext == _BookingAndUserContext.isAllowedToBook) {
  //   showAllowedToBookModal(context: context, booking: booking);
  //   return;
  // }

  if (booking.format == BookingFormat.merged) {
    showMultipleBookingsModal(context: context, booking: booking);
    return;
  }

  'Unknown modal'.tbLogger('Unknown modal', DebugLevel.error);
  return;
}

BookingDetailsType getBookingDetailsType(BookingAndUserContext bookingAndUserContext) {
  switch (bookingAndUserContext) {
    case BookingAndUserContext.isOwner:
      return BookingDetailsType.owner;
    case BookingAndUserContext.isParticipant:
      return BookingDetailsType.participant;
    case BookingAndUserContext.isOpenForInvites:
      return BookingDetailsType.openForInvites;
    case BookingAndUserContext.isNotMineAndPublic:
      return BookingDetailsType.notMineAndPublic;
    default:
      'Unknown BookingDetailsType'.tbLogger('Unknown BookingDetailsType', DebugLevel.error);
      return BookingDetailsType.notMineAndPublic;
  }
}
