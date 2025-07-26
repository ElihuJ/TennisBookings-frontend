import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../cloud_functions/cloud_functions_provider.dart';
import '../../../cloud_functions/dto/index.dart';
import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../global_widgets/icons/helper.dart';
import '../../../global_widgets/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/colors.dart';

class RequestContainer extends HookConsumerWidget {
  const RequestContainer({super.key, required this.request, required this.booking});

  final PopulatedRequest request;
  final BookingWithPopulatedRequest booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsNotifier = ref.read(clubsProvider.notifier);

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 350.0,
        margin: const EdgeInsets.only(bottom: 14.0),
        child: Card(
          elevation: 3,
          shadowColor: AppColors.primaryGreen,
          surfaceTintColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FutureBuilder<String>(
              future: clubsNotifier.getPlayerPhotoUrl(playerId: request.playerId),
              builder: (context, snapshot) {
                final photoUrl = snapshot.data ?? '';
                final playerData =
                    ConfirmedPlayerData(id: request.playerId, name: request.playerName, utrVerified: request.playerUtrVerified, photoUrl: photoUrl);

                if (request.status != BookingRequestStatus.pending) {
                  // if(true){}
                  return const SizedBox.shrink();
                }

                return _PlayerData(playerData: playerData, request: request, booking: booking);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerData extends StatelessWidget {
  const _PlayerData({
    required this.playerData,
    required this.request,
    required this.booking,
  });

  final ConfirmedPlayerData playerData;
  final PopulatedRequest request;
  final BookingWithPopulatedRequest booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            PlayerIcon(
              player: playerData,
              size: 60,
            ),
            const SizedBox(width: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PrettyText(request.playerName),
                const SizedBox(height: 4.0),
                UtrBox(
                  utrRating: request.playerUtrRating,
                  verified: request.playerUtrVerified,
                ),
                PrettyText(
                  'Gender: ${capitalizeFirstLetter(request.playerGender.name)}',
                  style: const TextStyle(fontSize: 14.0, color: AppColors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        _ActionButtons(booking: booking, request: request),
      ],
    );
  }
}

class _ActionButtons extends HookConsumerWidget {
  const _ActionButtons({required this.booking, required this.request});

  final BookingWithPopulatedRequest booking;
  final PopulatedRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudFunctions = ref.read(cloudFunctionsProvider.notifier);
    final userNotifier = ref.read(userProvider.notifier);
    final bookingsWithPopulatedRequests = ref.watch(userProvider).bookingsWithPopulatedRequests;
    final eventNotifier = ref.read(eventProvider.notifier);

    removeRequestFromState() {
      bookingsWithPopulatedRequests.remove(booking);
      final requests = booking.requests.where((r) => r.playerId != request.playerId).toList();
      final updatedBooking = booking.copyWith2(requests: requests);
      // * If the updated booking has no pending requests, remove it from the state
      if (updatedBooking.requests.any((request) => request.status == BookingRequestStatus.pending)) {
        bookingsWithPopulatedRequests.add(updatedBooking);
      }
      userNotifier.setBookingsWithPopulatedRequests(requests: bookingsWithPopulatedRequests);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            eventNotifier.showLoading(message: "Accepting Invite...");
            final actionInvitePayload = ActionInvitePayload(
              basicBookingPayload: BasicBookingPayload(bookingId: booking.id, clubId: booking.clubId, courtId: booking.courtId),
              inviteAction: InviteAction.accept,
              targetPlayerId: request.playerId,
            );
            final result = await cloudFunctions.actionInvite(actionInvitePayload);
            eventNotifier.hideLoading();

            if (result.data == true) {
              eventNotifier.showMessage(messageType: MessageType.success, message: "Invite accepted!");
              removeRequestFromState();
            } else {
              eventNotifier.showMessage(messageType: MessageType.error, message: result.errorMessage!);
            }
          },
          icon: const Icon(Icons.check),
          label: const PrettyText('Accept'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            eventNotifier.showLoading(message: "Declining Invite...");
            final actionInvitePayload = ActionInvitePayload(
              basicBookingPayload: BasicBookingPayload(bookingId: booking.id, clubId: booking.clubId, courtId: booking.courtId),
              inviteAction: InviteAction.reject,
              targetPlayerId: request.playerId,
            );
            final result = await cloudFunctions.actionInvite(actionInvitePayload);
            eventNotifier.hideLoading();

            if (result.data == true) {
              eventNotifier.showMessage(messageType: MessageType.success, message: "Invite declined!");
              removeRequestFromState();
            } else {
              eventNotifier.showMessage(messageType: MessageType.error, message: result.errorMessage!);
            }
          },
          icon: const Icon(Icons.close),
          label: const PrettyText('Decline'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }
}
