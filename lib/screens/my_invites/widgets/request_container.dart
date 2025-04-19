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
  const RequestContainer({super.key, required this.request, required this.booking, required this.removeInviteFromState});

  final BookingPopulatedRequest request;
  final BookingWithPopulatedRequest booking;
  final Function removeInviteFromState;

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

                return _PlayerData(playerData: playerData, request: request, booking: booking, removeInviteFromState: removeInviteFromState);
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
    required this.removeInviteFromState,
  });

  final ConfirmedPlayerData playerData;
  final BookingPopulatedRequest request;
  final BookingWithPopulatedRequest booking;
  final Function removeInviteFromState;

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
                Text(
                  request.playerName,
                  style: const TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                UtrBox(
                  utrRating: request.playerUtrRating,
                  verified: request.playerUtrVerified,
                  textStyle: const TextStyle(fontSize: 14.0, color: AppColors.grey),
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
        _ActionButtons(booking: booking, request: request, removeInviteFromState: removeInviteFromState),
      ],
    );
  }
}

class _ActionButtons extends HookConsumerWidget {
  const _ActionButtons({required this.booking, required this.request, required this.removeInviteFromState});

  final BookingWithPopulatedRequest booking;
  final BookingPopulatedRequest request;
  final Function removeInviteFromState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudFunctions = ref.read(cloudFunctionsProvider.notifier);
    final eventNotifier = ref.read(eventsProvider.notifier);
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
            removeInviteFromState(booking, request);
            eventNotifier.hideLoading();

            if (result.data == true) {
              eventNotifier.showMessage(messageType: MessageType.success, message: "Invite accepted!");
            } else {
              eventNotifier.showMessage(messageType: MessageType.error, message: result.errorMessage!);
            }
          },
          icon: const Icon(Icons.check),
          label: const Text('Accept'),
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
            removeInviteFromState(booking, request);
            eventNotifier.hideLoading();

            if (result.data == true) {
              eventNotifier.showMessage(messageType: MessageType.success, message: "Invite declined!");
            } else {
              eventNotifier.showMessage(messageType: MessageType.error, message: result.errorMessage!);
            }
          },
          icon: const Icon(Icons.close),
          label: const Text('Decline'),
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
