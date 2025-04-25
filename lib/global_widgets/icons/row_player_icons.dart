import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../cloud_functions/index.dart';
import '../../models/index.dart';
import '../../state/index.dart';
import '../index.dart';

enum SourceOfPlayerData {
  cloudFunction,
  firestore,
}

class RowOfPlayerIcons extends HookConsumerWidget {
  const RowOfPlayerIcons({
    super.key,
    required this.confirmedPlayerIds,
    required this.booking,
    required this.sourceOfPlayerData,
  });

  final List<String> confirmedPlayerIds;
  final Booking booking;
  final SourceOfPlayerData sourceOfPlayerData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudFunctions = ref.read(cloudFunctionsProvider.notifier);
    final clubsNotifier = ref.read(clubsProvider.notifier);
    final user = ref.watch(userProvider);

    return FutureBuilder<List<ConfirmedPlayerData>>(
      future: getPlayersDataCall(
        user: user,
        sourceOfPlayersData: sourceOfPlayerData,
        cloudFunctions: cloudFunctions,
        booking: booking,
        clubsNotifier: clubsNotifier,
      ),
      builder: (context, snapshot) {
        final confirmedPlayersPlusOwner = [...confirmedPlayerIds, booking.ownerId]; // * To be used only while loading or no data came back

        if (snapshot.connectionState == ConnectionState.waiting) {
          final confirmedPlayersPlusOwner = [...confirmedPlayerIds, booking.ownerId];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: confirmedPlayersPlusOwner.map((_) {
              return const CircularProgressIndicator();
            }).toList(),
          );
        }

        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          final players = snapshot.data!;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: players.map((player) {
              return Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    PlayerIcon(player: player),
                  ],
                ),
              );
            }).toList(),
          );
        }

        // * This block should never happen
        return _DefaultRowOfPlayerIcons(confirmedPlayerIds: confirmedPlayersPlusOwner);
      },
    );
  }
}

class _DefaultRowOfPlayerIcons extends StatelessWidget {
  const _DefaultRowOfPlayerIcons({
    required this.confirmedPlayerIds,
  });

  final List<String> confirmedPlayerIds;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: confirmedPlayerIds.map((_) {
        return const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.person),
        );
      }).toList(),
    );
  }
}
