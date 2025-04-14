import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../global_widgets/icons/helper.dart';
import '../../../global_widgets/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/colors.dart';

class RequestContainer extends HookConsumerWidget {
  const RequestContainer({super.key, required this.request});

  final BookingPopulatedRequest request;

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

                return _PlayerData(playerData: playerData, request: request);
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
  });

  final ConfirmedPlayerData playerData;
  final BookingPopulatedRequest request;

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
        _ActionButtons(),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Handle accept request
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
          onPressed: () {
            // Handle decline request
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
