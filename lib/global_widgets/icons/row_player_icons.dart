import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_helpers/logs.dart';

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
    required this.clubId,
    required this.sourceOfPlayerData,
  });

  final List<String> confirmedPlayerIds;
  final Booking booking;
  final String clubId;
  final SourceOfPlayerData sourceOfPlayerData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudFunctions = ref.watch(cloudFunctionsProvider.notifier);
    final clubsNotifier = ref.watch(clubsProvider.notifier);
    final user = ref.watch(userProvider);

    return FutureBuilder<List<ConfirmedPlayerData>>(
      future: getPlayersDataCall(
        user: user,
        sourceOfPlayersData: sourceOfPlayerData,
        cloudFunctions: cloudFunctions,
        booking: booking,
        clubId: clubId,
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
                    CachedNetworkImage(
                      imageUrl: player.photoUrl,
                      fit: BoxFit.cover,
                      cacheKey: player.photoUrl,
                      height: 30,
                      width: 30,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        backgroundImage: imageProvider,
                        radius: 15,
                      ),
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }

        // * This block should never happen
        return DefaultRowOfPlayerIcons(confirmedPlayerIds: confirmedPlayersPlusOwner);
      },
    );
  }
}

class DefaultRowOfPlayerIcons extends StatelessWidget {
  const DefaultRowOfPlayerIcons({
    super.key,
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
