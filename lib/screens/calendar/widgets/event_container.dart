import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../global_widgets/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';
import '../../calendar/widgets/index.dart';

// * This is the container that is displayed while in the main calendar view
class EventContainer extends HookConsumerWidget {
  const EventContainer({super.key, required this.events, required this.club});

  final List<CalendarEventData<Booking>> events;
  final Club club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    ref.watch(clubsProvider); // * This is to make sure the bookings are refreshing when there are changes

    final booking = events.first.event!;
    final confirmedPlayerIds = booking.confirmedPlayerIds;
    final isConfirmed = booking.status == BookingStatus.confirmed;
    final isMerged = booking.format == BookingFormat.merged;
    final isCoaching = booking.format == BookingFormat.coaching;
    final owned = booking.ownerId == user.uid;

    // * Computing colours
    Color bookingColor = owned ? AppColors.primaryGreen : AppColors.darkGreen;
    if (!isConfirmed || isMerged) {
      bookingColor = AppColors.primaryGreen.withValues(alpha: 0.5);
    }

    if (isCoaching) bookingColor = AppColors.blue;

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
    final bookingLengthEpoch = booking.endTime - booking.startTime;
    final bookingLessThanAnHour = bookingLengthEpoch < 3600;
    final fontSize = bookingLessThanAnHour ? 10.0 : 14.0;

    final onlyMembers = club.onlyMembers;

    final isMemberOfClub = user.memberships.any((membership) => membership.clubId == club.id);

    final bookingAndUserContext = getBookingAndUserContext(booking: booking, user: user, onlyMembers: onlyMembers, isMemberOfClub: isMemberOfClub);
    final (mouseAction, isClickable) = _getPermissionToClick(bookingAndUserContext: bookingAndUserContext);

    final isCoaching = booking.format == BookingFormat.coaching;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        final isPhone = maxWidth < 80;
        final isTablet = maxWidth >= 80 && maxWidth < 120;

        final maxWidthToUse = isPhone
            ? constraints.maxWidth - 20
            : isTablet
                ? constraints.maxWidth - 40
                : constraints.maxWidth - 60;

        return MouseRegion(
          cursor: mouseAction,
          onHover: (event) {},
          child: GestureDetector(
            onTap: () => _onTapAction(
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: maxWidthToUse,
                          child: PrettyText(
                            event.title,
                            style: TextStyle(color: computedTextColor, fontSize: fontSize),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                        if (booking.private)
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.lock,
                                size: 18,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        if (isCoaching)
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.sports_tennis,
                                size: 18,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    PlayerIcons(
                      confirmedPlayerIds: confirmedPlayerIds,
                      booking: booking,
                      type: PlayerIconsType.row,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

BookingAndUserContext getBookingAndUserContext(
    {required Booking booking, required User user, required bool onlyMembers, required bool isMemberOfClub}) {
  final clubIsPublicOrMemberOfClub = !onlyMembers || isMemberOfClub;

  if (user.uid.isEmpty) return BookingAndUserContext.isNotLoggedIn;
  if (onlyMembers && !isMemberOfClub) return BookingAndUserContext.isNotAllowedToBook;
  if (booking.ownerId == user.uid) return BookingAndUserContext.isOwner;
  if (booking.confirmedPlayerIds.contains(user.uid)) return BookingAndUserContext.isParticipant;
  if (booking.format == BookingFormat.merged) return BookingAndUserContext.isMergedBooking; // * This needs to come before open bookings
  if (clubIsPublicOrMemberOfClub && booking.status == BookingStatus.open) return BookingAndUserContext.isOpenForInvites;
  if (booking.status == BookingStatus.confirmed && booking.ownerId != user.uid && booking.private) return BookingAndUserContext.isNotMineAndPrivate;
  if (booking.status == BookingStatus.confirmed && booking.ownerId != user.uid && !booking.private) return BookingAndUserContext.isNotMineAndPublic;

  if (!onlyMembers) return BookingAndUserContext.isOpenForInvites;
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
    showBookingDetailsModal(context: context, booking: booking, bookingDetailsType: bookingDetailsType);
    return;
  }

  if (booking.format == BookingFormat.merged) {
    showMultipleBookingsModal(context: context, booking: booking);
    return;
  }

  'unknown modal'.tbLogger('unknown modal', DebugLevel.error);
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
      'unknown BookingDetailsType'.tbLogger('unknown BookingDetailsType', DebugLevel.error);
      return BookingDetailsType.notMineAndPublic;
  }
}
