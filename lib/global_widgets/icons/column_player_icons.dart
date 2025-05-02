import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../cloud_functions/dto/get_confirmed_players.dart';
import '../../cloud_functions/dto/index.dart';
import '../../cloud_functions/index.dart';
import '../../global_helpers/index.dart';
import '../../models/index.dart';
import '../../state/index.dart';
import '../../theme/index.dart';
import '../containers/bordered_box.dart';
import '../index.dart';
import 'helper.dart';

class ColumnOfPlayerIcons extends StatefulHookConsumerWidget {
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
  ConsumerState createState() => _ColumnOfPlayerIconsState();
}

class _ColumnOfPlayerIconsState extends ConsumerState<ColumnOfPlayerIcons> {
  late Future<List<ConfirmedPlayerData>> playersDataFuture;
  @override
  void initState() {
    super.initState();
    final cloudFunctions = ref.read(cloudFunctionsProvider.notifier);
    final clubsNotifier = ref.read(clubsProvider.notifier);
    final user = ref.read(userProvider);

    playersDataFuture = getPlayersDataCall(
      user: user,
      sourceOfPlayersData: widget.sourceOfPlayersData,
      cloudFunctions: cloudFunctions,
      booking: widget.booking,
      clubsNotifier: clubsNotifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConfirmedPlayerData>>(
      future: playersDataFuture,
      builder: (context, snapshot) {
        final confirmedPlayersPlusOwner = [
          ...widget.confirmedPlayerIds,
          widget.booking.ownerId
        ]; // * To be used only while loading or no data came back

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: confirmedPlayersPlusOwner.map((_) {
              return LoadingRow();
            }).toList(),
          );
        }

        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          var players = snapshot.data!;
          players = [
            ...players,
            ...players,
            ...players,
            ...players,
          ];

          final screenHeight = MediaQuery.of(context).size.height;
          final containerHeight = screenHeight < 600 ? 0.3 * screenHeight : 0.5 * screenHeight;

          return SizedBox(
            height: containerHeight,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: players.map((player) {
                  return _PlayerDataRow(player: player);
                }).toList(),
              ),
            ),
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
    final mobile = isMobile(context);
    return BorderedBox(
      margin: const EdgeInsets.symmetric(vertical: 5),
      borderColor: Colors.transparent,
      backgroundColor: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 5),
      height: 100,
      child: mobile ? _MobileView(player: player) : _DesktopView(player: player),
    );
  }
}

class _DesktopView extends StatelessWidget {
  const _DesktopView({required this.player});

  final ConfirmedPlayerData player;
  final double iconSize = 70;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: space,
      children: [
        FieldBox(
          width: iconSize,
          child: PlayerIcon(player: player, size: iconSize),
        ),
        if (player.name.isNotEmpty)
          FieldBox(
              width: nameWidth,
              child: Text(
                player.name,
                style: TextStyle(fontSize: 16),
              )),
        if (player.utrRating != null) FieldBox(width: utrWidth, child: UtrBox(utrRating: player.utrRating, verified: player.utrVerified))
      ],
    );
  }
}

class _MobileView extends StatelessWidget {
  const _MobileView({required this.player});

  final ConfirmedPlayerData player;
  final double iconSize = 40;
  final double fontSize = 14;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: space,
      children: [
        FieldBox(
          width: iconSize,
          child: PlayerIcon(
            player: player,
            size: iconSize,
          ),
        ),
        if (player.name.isNotEmpty)
          Column(
            children: [
              FieldBox(
                  width: nameWidth,
                  child: Text(
                    player.name,
                    style: TextStyle(
                      fontSize: fontSize,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
              if (player.utrRating != null)
                FieldBox(
                  width: utrWidth,
                  child: UtrBox(
                    utrRating: player.utrRating,
                    verified: player.utrVerified,
                    textStyle: TextStyle(
                      fontSize: fontSize,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
            ],
          ),
      ],
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
