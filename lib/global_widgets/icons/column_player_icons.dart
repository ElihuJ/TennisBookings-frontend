import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../cloud_functions/dto/get_confirmed_players.dart';
import '../../cloud_functions/dto/index.dart';
import '../../cloud_functions/index.dart';
import '../../models/index.dart';
import '../../state/index.dart';
import '../../theme/index.dart';
import '../containers/bordered_box.dart';
import '../index.dart';
import 'helper.dart';

class ColumnOfPlayerIcons extends HookConsumerWidget {
  const ColumnOfPlayerIcons({
    super.key,
    required this.confirmedPlayerIds,
    required this.booking,
    required this.sourceOfPlayersData,
  });

  final List<String> confirmedPlayerIds;
  final Booking booking;
  final SourceOfPlayerData sourceOfPlayersData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudFunctions = ref.watch(cloudFunctionsProvider.notifier);
    final clubsNotifier = ref.watch(clubsProvider.notifier);
    final user = ref.watch(userProvider);

    return FutureBuilder<List<ConfirmedPlayerData>>(
      future: getPlayersDataCall(
        sourceOfPlayersData: sourceOfPlayersData,
        cloudFunctions: cloudFunctions,
        clubsNotifier: clubsNotifier,
        booking: booking,
        user: user,
      ),
      builder: (context, snapshot) {
        final confirmedPlayersPlusOwner = [...confirmedPlayerIds, booking.ownerId]; // * To be used only while loading or no data came back

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: confirmedPlayersPlusOwner.map((_) {
              return LoadingRow();
            }).toList(),
          );
        }

        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          final players = snapshot.data!;

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: players.map((player) {
              return _PlayerDataRow(player: player);
            }).toList(),
          );
        }

        // * This block should never happen
        return DefaultColumnOfPlayerIcons(confirmedPlayerIds: confirmedPlayersPlusOwner);
      },
    );
  }
}

Future<List<ConfirmedPlayerData>> getPlayersDataCall({
  required SourceOfPlayerData sourceOfPlayersData,
  required CloudFunctionsNotifier cloudFunctions,
  required ClubsNotifier clubsNotifier,
  required Booking booking,
  required User user,
}) {
  if (user.uid.isEmpty) {
    return Future.value([]);
  }
  if (sourceOfPlayersData == SourceOfPlayerData.cloudFunction) {
    final payload = GetConfirmedPlayersDataPayload(
      payload: BasicBookingPayload(
        bookingId: booking.id,
        clubId: booking.clubId,
        courtId: booking.courtId,
      ),
    );
    return cloudFunctions.getConfirmedPlayersData(payload).then((value) => value.data!);
  } else {
    return clubsNotifier.getPublicPlayerData(booking: booking, user: user);
  }
}

class _PlayerDataRow extends StatelessWidget {
  const _PlayerDataRow({required this.player});

  final ConfirmedPlayerData player;

  @override
  Widget build(BuildContext context) {
    return BorderedBox(
      margin: const EdgeInsets.symmetric(vertical: 5),
      borderColor: Colors.transparent,
      backgroundColor: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 5),
      height: 100,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: space,
        children: [
          FieldBox(
            width: 70,
            child: PlayerIcon(
              player: player,
              size: 70,
            ),
          ),
          if (player.name.isNotEmpty)
            FieldBox(
                width: nameWidth,
                child: Text(
                  player.name,
                  style: TextStyle(fontSize: 16),
                )),
          if (player.utrRating != null) FieldBox(width: utrWidth, child: UtrBox(utrRating: player.utrRating, verified: player.utrVerified)),
        ],
      ),
    );
  }
}

class DefaultColumnOfPlayerIcons extends StatelessWidget {
  const DefaultColumnOfPlayerIcons({
    super.key,
    required this.confirmedPlayerIds,
  });

  final List<String> confirmedPlayerIds;

  @override
  Widget build(BuildContext context) {
    return Column(
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
