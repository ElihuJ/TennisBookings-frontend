import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/cloud_functions/dto/delete_booking.dart';
import 'package:tennisbookings/cloud_functions/dto/send_invite.dart';
import 'package:tennisbookings/cloud_functions/dto/withdraw_from_booking.dart';

import '../../../cloud_functions/dto/index.dart';
import '../../../cloud_functions/index.dart';
import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';
import '../../../screens/club/widgets/index.dart';
import '../../../state/index.dart';
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

    return EventfulWidget(
      child: AlertDialog(
        title: PrettyText(
          booking.title,
          maxLines: 3,
        ),
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
        actions: _getActions(context: context, bookingDetailsType: bookingDetailsType, widgetRef: ref, booking: booking),
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }
}

_getOwnerActions({
  required BuildContext context,
  required Booking booking,
  required WidgetRef widgetRef,
}) {
  final eventNotifier = widgetRef.read(eventsProvider.notifier);
  final cloudFunctions = widgetRef.read(cloudFunctionsProvider.notifier);
  final clubsNotifier = widgetRef.read(clubsProvider.notifier);

  return [
    TbTextButton(
      onPressed: () async {
        eventNotifier.showLoading(message: "Deleting event...");
        await wait(1000);
        BasicBookingPayload payload = BasicBookingPayload(bookingId: booking.id, clubId: booking.clubId, courtId: booking.courtId);
        final result = await cloudFunctions.deleteBooking(DeleteBookingPayload(payload: payload));
        eventNotifier.hideLoading();
        if (result.data == true) {
          eventNotifier.showMessage(messageType: MessageType.success, message: "Event deleted");
          clubsNotifier.removeBooking(booking: booking);
          if (context.mounted) Navigator.of(context).pop();
          return;
        }
        eventNotifier.showMessage(messageType: MessageType.error, message: result.errorMessage!);
      },
      color: Colors.red,
      text: 'Delete',
      height: 40,
    ),
  ];
}

_getParticipantActions({
  required BuildContext context,
  required Booking booking,
  required WidgetRef widgetRef,
}) {
  final eventNotifier = widgetRef.read(eventsProvider.notifier);
  final cloudFunctions = widgetRef.read(cloudFunctionsProvider.notifier);
  final clubsNotifier = widgetRef.read(clubsProvider.notifier);
  final userId = widgetRef.read(userProvider).uid;
  return [
    TbTextButton(
      onPressed: () async {
        eventNotifier.showLoading(message: "Withdrawing from booking...");
        await wait(1000);
        WithdrawFromBookingPayload payload =
            WithdrawFromBookingPayload(payload: BasicBookingPayload(bookingId: booking.id, clubId: booking.clubId, courtId: booking.courtId));
        final result = await cloudFunctions.withdrawFromBooking(payload);
        eventNotifier.hideLoading();
        if (result.data == true) {
          eventNotifier.showMessage(messageType: MessageType.success, message: "Successfully withdrawn!");
          final updatedBooking = booking.copyWith(confirmedPlayerIds: booking.confirmedPlayerIds..remove(userId), status: BookingStatus.open);
          clubsNotifier.updateBooking(booking: updatedBooking, userId: userId);
          if (context.mounted) Navigator.of(context).pop();
          return;
        }
        eventNotifier.showMessage(messageType: MessageType.error, message: result.errorMessage!);
      },
      color: Colors.red,
      text: 'Withdraw',
      height: 40,
    ),
  ];
}

_getOpenForInvitesActions({
  required BuildContext context,
  required Booking booking,
  required WidgetRef widgetRef,
}) {
  final eventNotifier = widgetRef.read(eventsProvider.notifier);
  final cloudFunctions = widgetRef.read(cloudFunctionsProvider.notifier);
  final userId = widgetRef.watch(userProvider).uid;
  final requestAlreadySent = booking.requests.map((element) => element.playerId == userId);

  final onTapAction = requestAlreadySent.isNotEmpty
      ? null
      : () async {
          eventNotifier.showLoading(message: "Sending request to join...");
          await wait(1000);
          SendInvitePayload payload =
              SendInvitePayload(payload: BasicBookingPayload(bookingId: booking.id, clubId: booking.clubId, courtId: booking.courtId));
          final result = await cloudFunctions.sendInvite(payload);
          eventNotifier.hideLoading();
          if (result.data == true) {
            booking.requests.add(BookingRequest(playerId: userId, status: BookingRequestStatus.pending));
            eventNotifier.showMessage(messageType: MessageType.success, message: "Request sent!");
            if (context.mounted) Navigator.of(context).pop();
            return;
          }
          eventNotifier.showMessage(messageType: MessageType.error, message: result.errorMessage!);
        };

  return [
    TbTextButton(
      onPressed: onTapAction,
      color: Colors.green,
      text: requestAlreadySent.contains(true) ? 'Request sent' : 'Request to join',
      height: 40,
    ),
  ];
}

_getActions({
  required BuildContext context,
  required BookingDetailsType bookingDetailsType,
  required Booking booking,
  required WidgetRef widgetRef,
}) {
  switch (bookingDetailsType) {
    case BookingDetailsType.owner:
      return _getOwnerActions(context: context, widgetRef: widgetRef, booking: booking);
    case BookingDetailsType.participant:
      return _getParticipantActions(context: context, widgetRef: widgetRef, booking: booking);
    case BookingDetailsType.openForInvites:
      return _getOpenForInvitesActions(context: context, widgetRef: widgetRef, booking: booking);
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
