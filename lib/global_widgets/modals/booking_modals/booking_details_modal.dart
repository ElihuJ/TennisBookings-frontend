import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web/web.dart' as web;

import '../../../cloud_functions/dto/delete_booking.dart';
import '../../../cloud_functions/dto/index.dart';
import '../../../cloud_functions/dto/send_invite.dart';
import '../../../cloud_functions/dto/withdraw_from_booking.dart';
import '../../../cloud_functions/index.dart';
import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';
import '../../../screens/calendar/calendar_screen.dart';
import '../../../screens/calendar/widgets/index.dart';
import '../../../state/index.dart';
import '../../../strings/index.dart';
import '../../../theme/colors.dart';
import '../../index.dart';
import '../widget/modal_shell.dart';

enum BookingDetailsType { owner, participant, openForInvites, notMineAndPublic }

class BookingDetailsModal extends HookConsumerWidget {
  const BookingDetailsModal({super.key, required this.booking, required this.bookingDetailsType, required this.multipleBookingsView});

  final Booking booking;
  final BookingDetailsType bookingDetailsType;
  final bool multipleBookingsView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startMs = booking.startTime;
    final endMs = booking.endTime;
    final actions = _getActions(context: context, bookingDetailsType: bookingDetailsType, widgetRef: ref, booking: booking);

    if (multipleBookingsView) {
      return _BookingCard(booking: booking, startMs: startMs, endMs: endMs, actions: actions);
    }

    return EventfulWidget(
      child: ModalShell(
        icon: Icons.sports_tennis,
        title: booking.title,
        subtitle: '${prettyDateLocalFromEpoch(startMs)}  ·  ${getLocalTimeFromEpoch(startMs)} – ${getLocalTimeFromEpoch(endMs)}',
        body: _BookingBody(booking: booking, startMs: startMs, endMs: endMs),
        actions: actions,
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.startMs,
    required this.endMs,
    required this.actions,
  });

  final Booking booking;
  final int startMs;
  final int endMs;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.courtGreen, AppColors.darkGreen],
              ),
            ),
            child: Column(
              children: [
                Text(
                  booking.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${prettyDateLocalFromEpoch(startMs)}  ·  ${getLocalTimeFromEpoch(startMs)} – ${getLocalTimeFromEpoch(endMs)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _BookingBody(booking: booking, startMs: startMs, endMs: endMs),
          ),
          if (actions != null && actions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  for (int i = 0; i < actions!.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: actions![i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BookingBody extends HookConsumerWidget {
  const _BookingBody({required this.booking, required this.startMs, required this.endMs});

  final Booking booking;
  final int startMs;
  final int endMs;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final eventNotifier = widgetRef.read(eventProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlayerIcons(confirmedPlayerIds: booking.confirmedPlayerIds, booking: booking, type: PlayerIconsType.column),
        const SizedBox(height: 12),
        if (booking.courtPin != null)
          _PinRow(
            icon: Icons.meeting_room_outlined,
            label: context.localeString(BookingModalStrings.courtPin),
            value: booking.courtPin!,
          ),
        if (booking.clubPin != null)
          _PinRow(
            icon: Icons.lock_open_outlined,
            label: context.localeString(BookingModalStrings.clubPin),
            value: booking.clubPin!,
          ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Material(
            color: AppColors.surfaceGreenAlt,
            child: InkWell(
              onTap: () async {
                final url =
                    '${web.window.origin}#${CalendarScreen.route}?clubId=${booking.clubId}&courtId=${booking.courtId}&bookingId=${booking.id}&time=$startMs';
                await Clipboard.setData(ClipboardData(text: url));
                eventNotifier.showMessage(messageType: MessageType.success, message: context.localeString(BookingModalStrings.linkCopied));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderGreen),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.localeString(BookingModalStrings.shareBooking),
                        style: const TextStyle(color: AppColors.textBody, fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ),
                    const Icon(Icons.content_copy_outlined, size: 15, color: AppColors.textSubtle),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PinRow extends StatelessWidget {
  const _PinRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceGreenAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderGreen),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(color: AppColors.textBody, fontWeight: FontWeight.w500, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

List<Widget> _getOwnerActions({
  required BuildContext context,
  required Booking booking,
  required WidgetRef widgetRef,
}) {
  final eventNotifier = widgetRef.read(eventProvider.notifier);
  final cloudFunctions = widgetRef.read(cloudFunctionsProvider.notifier);
  final clubsNotifier = widgetRef.read(clubsProvider.notifier);
  final userNotifier = widgetRef.read(userProvider.notifier);

  return [
    FilledButton(
      onPressed: () async {
        eventNotifier.showLoading(message: context.localeString(BookingModalStrings.deleting));
        final payload =
            DeleteBookingPayload(payload: BasicBookingPayload(bookingId: booking.id, clubId: booking.clubId, courtId: booking.courtId));
        final result = await cloudFunctions.deleteBooking(payload);
        eventNotifier.hideLoading();
        if (result.data == true) {
          eventNotifier.showMessage(messageType: MessageType.success, message: context.localeString(BookingModalStrings.eventDeleted));
          clubsNotifier.removeBooking(booking: booking);
          userNotifier.removeBooking(booking.id);
          if (context.mounted) Navigator.of(context).pop();
          return;
        }
        eventNotifier.showMessage(messageType: MessageType.error, message: result.errorMessage!);
      },
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.dangerRed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(context.localeString(GeneralStrings.delete)),
    ),
  ];
}

List<Widget> _getParticipantActions({
  required BuildContext context,
  required Booking booking,
  required WidgetRef widgetRef,
}) {
  final eventNotifier = widgetRef.read(eventProvider.notifier);
  final cloudFunctions = widgetRef.read(cloudFunctionsProvider.notifier);
  final clubsNotifier = widgetRef.read(clubsProvider.notifier);
  final userNotifier = widgetRef.read(userProvider.notifier);
  final userId = widgetRef.read(userProvider).uid;

  return [
    FilledButton(
      onPressed: () async {
        eventNotifier.showLoading(message: context.localeString(BookingModalStrings.withdrawing));
        final payload = WithdrawFromBookingPayload(
            payload: BasicBookingPayload(bookingId: booking.id, clubId: booking.clubId, courtId: booking.courtId));
        final result = await cloudFunctions.withdrawFromBooking(payload);
        eventNotifier.hideLoading();
        if (result.data == true) {
          eventNotifier.showMessage(messageType: MessageType.success, message: context.localeString(BookingModalStrings.withdrawn));
          final updatedBooking =
              booking.copyWith(confirmedPlayerIds: booking.confirmedPlayerIds..remove(userId), status: BookingStatus.open);
          clubsNotifier.updateBooking(booking: updatedBooking, userId: userId);
          userNotifier.removeBooking(booking.id);
          if (context.mounted) Navigator.of(context).pop();
          return;
        }
        eventNotifier.showMessage(messageType: MessageType.error, message: result.errorMessage!);
      },
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.dangerRed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(context.localeString(BookingModalStrings.withdrawBtn)),
    ),
  ];
}

List<Widget> _getOpenForInvitesActions({
  required BuildContext context,
  required Booking booking,
  required WidgetRef widgetRef,
}) {
  final eventNotifier = widgetRef.read(eventProvider.notifier);
  final cloudFunctions = widgetRef.read(cloudFunctionsProvider.notifier);
  final userId = widgetRef.watch(userProvider).uid;

  final requestAlreadySent = booking.requests.firstWhereOrNull((r) => r.playerId == userId) != null;
  final inThePast = isInThePast(booking.startTime);

  final onTap = requestAlreadySent || inThePast
      ? null
      : () async {
          eventNotifier.showLoading(message: context.localeString(BookingModalStrings.sendingRequest));
          final payload =
              SendInvitePayload(payload: BasicBookingPayload(bookingId: booking.id, clubId: booking.clubId, courtId: booking.courtId));
          final result = await cloudFunctions.sendInvite(payload);
          eventNotifier.hideLoading();
          if (result.data == true) {
            booking.requests.add(BookingRequest(playerId: userId, status: BookingRequestStatus.pending));
            eventNotifier.showMessage(messageType: MessageType.success, message: context.localeString(BookingModalStrings.requestSentMsg));
            if (context.mounted) Navigator.of(context).pop();
            return;
          }
          eventNotifier.showMessage(messageType: MessageType.error, message: result.errorMessage!);
        };

  final buttonText = inThePast
      ? context.localeString(BookingModalStrings.bookingClosed)
      : requestAlreadySent
          ? context.localeString(BookingModalStrings.requestSentBtn)
          : context.localeString(BookingModalStrings.requestToJoin);

  return [
    FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        disabledBackgroundColor: AppColors.disabledGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(buttonText),
    ),
  ];
}

List<Widget>? _getActions({
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
      return null;
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
