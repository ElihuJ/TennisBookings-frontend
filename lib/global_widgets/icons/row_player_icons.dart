import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../cloud_functions/index.dart';
import '../../global_helpers/index.dart';
import '../../models/index.dart';
import '../../state/index.dart';
import '../index.dart';

enum SourceOfPlayerData {
  cloudFunction,
  firestore,
}

class RowOfPlayerIcons extends StatefulHookConsumerWidget {
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
  ConsumerState createState() => _RowOfPlayerIconsState();
}

class _RowOfPlayerIconsState extends ConsumerState<RowOfPlayerIcons> {
  late Future<List<ConfirmedPlayerData>> playersDataFuture;

  @override
  void initState() {
    super.initState();
    final cloudFunctions = ref.read(cloudFunctionsProvider.notifier);
    final clubsNotifier = ref.read(clubsProvider.notifier);
    final user = ref.read(userProvider);

    playersDataFuture = getPlayersDataCall(
      user: user,
      sourceOfPlayersData: widget.sourceOfPlayerData,
      cloudFunctions: cloudFunctions,
      booking: widget.booking,
      clubsNotifier: clubsNotifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    final confirmedPlayersPlusOwner = [...widget.confirmedPlayerIds, widget.booking.ownerId];

    final mobileView = isMobile(context);

    if (mobileView) return Container();

    return FutureBuilder<List<ConfirmedPlayerData>>(
      future: playersDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
