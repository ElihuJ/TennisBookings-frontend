import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../cloud_functions/dto/delete_booking.dart';
import '../../../cloud_functions/dto/index.dart';
import '../../../cloud_functions/dto/send_invite.dart';
import '../../../cloud_functions/dto/withdraw_from_booking.dart';
import '../../../cloud_functions/index.dart';
import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';
import '../../../screens/calendar/widgets/index.dart';
import '../../../state/index.dart';
import '../../index.dart';

enum BookingDetailsType { owner, participant, openForInvites, notMineAndPublic }

class BookingDetailsModal extends HookConsumerWidget {
  const BookingDetailsModal({super.key, required this.booking, required this.bookingDetailsType, required this.multipleBookingsView});

  final Booking booking;
  final BookingDetailsType bookingDetailsType;
  final bool multipleBookingsView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fromInMilliseconds = booking.startTime;
    final toInMilliseconds = booking.endTime;

    final alertDialog = AlertDialog(
      title: _ContainerTitle(booking: booking, fromInMilliseconds: fromInMilliseconds, toInMilliseconds: toInMilliseconds),
      content: _BookingContainer(booking: booking, fromInMilliseconds: fromInMilliseconds, toInMilliseconds: toInMilliseconds),
      actions: _getActions(context: context, bookingDetailsType: bookingDetailsType, widgetRef: ref, booking: booking),
      actionsAlignment: MainAxisAlignment.center,
    );

    if (multipleBookingsView) {
      return alertDialog;
    }

    return EventfulWidget(child: alertDialog);
  }
}

class _ContainerTitle extends StatelessWidget {
  const _ContainerTitle({
    required this.booking,
    required this.fromInMilliseconds,
    required this.toInMilliseconds,
  });

  final Booking booking;
  final int fromInMilliseconds;
  final int toInMilliseconds;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(padding: const EdgeInsets.only(right: 8.0), child: PrettyText(booking.title, maxLines: 3)),
          Padding(padding: const EdgeInsets.only(right: 8.0), child: PrettyText(prettyDateLocalFromEpoch(fromInMilliseconds))),
          Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: PrettyText('${getLocalTimeFromEpoch(fromInMilliseconds)} - ${getLocalTimeFromEpoch(toInMilliseconds)}')),
        ],
      ),
    );
  }
}

class _BookingContainer extends StatelessWidget {
  const _BookingContainer({
    required this.booking,
    required this.fromInMilliseconds,
    required this.toInMilliseconds,
  });

  final Booking booking;
  final int fromInMilliseconds;
  final int toInMilliseconds;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            PlayerIcons(confirmedPlayerIds: booking.confirmedPlayerIds, booking: booking, type: PlayerIconsType.column),
            const SizedBox(height: 15),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

_getOwnerActions({
  required BuildContext context,
  required Booking booking,
  required WidgetRef widgetRef,
}) {
  final eventNotifier = widgetRef.read(eventProvider.notifier);
  final cloudFunctions = widgetRef.read(cloudFunctionsProvider.notifier);
  final clubsNotifier = widgetRef.read(clubsProvider.notifier);

  return [
    TbTextButton(
      onPressed: () async {
        eventNotifier.showLoading(message: "Deleting event...");
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
    ),
  ];
}

_getParticipantActions({
  required BuildContext context,
  required Booking booking,
  required WidgetRef widgetRef,
}) {
  final eventNotifier = widgetRef.read(eventProvider.notifier);
  final cloudFunctions = widgetRef.read(cloudFunctionsProvider.notifier);
  final clubsNotifier = widgetRef.read(clubsProvider.notifier);
  final userId = widgetRef.read(userProvider).uid;
  return [
    TbTextButton(
      onPressed: () async {
        eventNotifier.showLoading(message: "Withdrawing from booking...");
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
    ),
  ];
}

_getOpenForInvitesActions({
  required BuildContext context,
  required Booking booking,
  required WidgetRef widgetRef,
}) {
  final eventNotifier = widgetRef.read(eventProvider.notifier);
  final cloudFunctions = widgetRef.read(cloudFunctionsProvider.notifier);
  final userId = widgetRef.watch(userProvider).uid;

  final requestAlreadySent = booking.requests.firstWhereOrNull((request) => request.playerId == userId) != null;
  final inThePast = isInThePast(booking.startTime);

  final onTapAction = requestAlreadySent || inThePast
      ? null
      : () async {
          eventNotifier.showLoading(message: "Sending request to join...");
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

  String buttonText = '';

  if (inThePast) {
    buttonText = 'Booking closed';
  } else if (requestAlreadySent) {
    buttonText = 'Request sent';
  } else {
    buttonText = 'Request to join';
  }

  return [
    TbTextButton(
      onPressed: onTapAction,
      color: Colors.green,
      text: buttonText,
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
      return BookingDetailsModal(booking: booking, bookingDetailsType: bookingDetailsType, multipleBookingsView: false);
    },
  );
}
