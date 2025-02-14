import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_helpers/index.dart';
import '../../../models/index.dart';
import '../../../screens/club/widgets/index.dart';
import '../../index.dart';

enum BookingDetailsType { owner, participant, openForInvites, notMineAndPublic }

class BookingDetailsModal extends HookConsumerWidget {
  const BookingDetailsModal({super.key, required this.booking, required this.bookingDetailsType});

  final Booking booking;
  final BookingDetailsType bookingDetailsType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fromInMilliseconds = booking.from * 1000;
    final toInMilliseconds = booking.to * 1000;

    return AlertDialog(
      title: PrettyText(booking.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 15),
          PlayerIcons(confirmedPlayerIds: booking.confirmedPlayerIds, booking: booking, type: PlayerIconsType.column),
          const SizedBox(height: 15),
          PrettyText(prettyDateLocalFromEpochMilliseconds(fromInMilliseconds)),
          PrettyText('${getLocalTimeFromEpochMilliseconds(fromInMilliseconds)} - ${getLocalTimeFromEpochMilliseconds(toInMilliseconds)}'),
          const SizedBox(height: 15),
        ],
      ),
      actions: _getActions(context: context, bookingDetailsType: bookingDetailsType),
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}

_getOwnerActions(BuildContext context) {
  return [
    TbTextButton(
      onPressed: () {},
      color: Colors.red,
      text: 'Delete',
      height: 40,
    ),
  ];
}

_getParticipantActions(BuildContext context) {
  return [
    TbTextButton(
      onPressed: () {},
      color: Colors.red,
      text: 'Leave',
      height: 40,
    ),
  ];
}

_getOpenForInvitesActions(BuildContext context) {
  return [
    TbTextButton(
      onPressed: () {},
      color: Colors.green,
      text: 'Send Invite',
      height: 40,
    ),
  ];
}

_getActions({required BuildContext context, required BookingDetailsType bookingDetailsType}) {
  switch (bookingDetailsType) {
    case BookingDetailsType.owner:
      return _getOwnerActions(context);
    case BookingDetailsType.participant:
      return _getParticipantActions(context);
    case BookingDetailsType.openForInvites:
      return _getOpenForInvitesActions(context);
    case BookingDetailsType.notMineAndPublic:
      return;
  }
}

void showBookingDetailsModal({required BuildContext context, required Booking booking, required BookingDetailsType bookingDetailsType}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BookingDetailsModal(booking: booking, bookingDetailsType: bookingDetailsType);
    },
  );
}
