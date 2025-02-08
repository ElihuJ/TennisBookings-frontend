import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/models/index.dart';

import '../../cloud_functions/dto/index.dart';
import '../../cloud_functions/index.dart';
import '../../cloud_functions/types.dart';

class RowOfPlayerIcons extends HookConsumerWidget {
  const RowOfPlayerIcons({
    super.key,
    required this.confirmedPlayerIds,
    required this.booking,
    required this.clubId,
  });

  final List<String> confirmedPlayerIds;
  final Booking booking;
  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudFunctions = ref.watch(cloudFunctionsProvider.notifier);

    final cfPayload = GetConfirmedPlayersDataPayload(
      bookingId: booking.id,
      clubId: clubId,
      courtId: booking.courtId,
    );
    final mockReturn = cloudFunctions.getConfirmedPlayersData(cfPayload);

    return FutureBuilder<CFResult<List<ConfirmedPlayerData>>>(
      future: mockReturn,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: confirmedPlayerIds.map((_) {
              return const CircularProgressIndicator();
            }).toList(),
          );
        }

        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          final response = snapshot.data!;

          if (response.responseStatus == CFResponseStatus.ok) {
            final players = response.data!;
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
        }

        // * This block should never happen
        return DefaultRowOfPlayerIcons(confirmedPlayerIds: confirmedPlayerIds);
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
