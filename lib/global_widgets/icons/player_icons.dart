import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_helpers/logs.dart';
import 'package:tennisbookings/models/index.dart';

import '../../state/index.dart';

enum IconsOrientation {
  horizontal,
  vertical,
}

class PlayerIcons extends HookConsumerWidget {
  const PlayerIcons({
    super.key,
    required this.confirmedPlayerIds,
    required this.orientation,
  });

  final List<String> confirmedPlayerIds;
  final IconsOrientation orientation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userProvider).uid;

    final allPlayerIds = [
      userId,
      ...confirmedPlayerIds,
      ConfirmedPlayerData(
        id: 'loading data',
        name: '',
        email: '',
        utrRating: 0,
        utrVerified: false,
        photoUrl: '',
      ),
      ConfirmedPlayerData(
        id: 'loading data',
        name: '',
        email: '',
        utrRating: 0,
        utrVerified: false,
        photoUrl: '',
      ),
      ConfirmedPlayerData(
        id: 'loading data',
        name: '',
        email: '',
        utrRating: 0,
        utrVerified: false,
        photoUrl: '',
      ),
    ];

    // Fetch data for all confirmed players

    final List<ConfirmedPlayerData> mockData = [
      ConfirmedPlayerData(
        id: userId,
        name: 'Amanda',
        email: 'a@a.com',
        utrRating: 0,
        utrVerified: false,
        photoUrl: '',
      ),
      ConfirmedPlayerData(
        id: 'userId',
        name: 'Elihu',
        email: 'a@a.com',
        utrVerified: false,
        photoUrl:
            'http://192.168.86.246:9199/v0/b/tennisbookings.appspot.com/o/public_profiles%2Fd9U6EkXxb8i9oCTNxBUMLEQLqRxC%2Fprofile.png?alt=media&token=352f4d5e-ba88-45d2-93a6-611c83aed311',
      ),
      ConfirmedPlayerData(
        id: userId,
        name: 'Roger',
        email: 'a@a.com',
        utrRating: 0,
        utrVerified: false,
        photoUrl: '',
      ),
      ConfirmedPlayerData(
        id: 'userId',
        name: 'Paula',
        email: 'a@a.com',
        utrVerified: false,
        photoUrl: '',
      ),
    ];

    final List<ConfirmedPlayerData> loadingData = [
      ConfirmedPlayerData(
        id: 'loading data',
        name: 'Loading...',
        email: '',
        utrRating: 0,
        utrVerified: false,
        photoUrl: '',
      ),
    ];

    final mockReturn = Future.delayed(Duration(seconds: 2)).then((_) => mockData);

    return FutureBuilder<List<ConfirmedPlayerData>>(
      future: mockReturn,
      initialData: loadingData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (orientation == IconsOrientation.vertical) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: allPlayerIds.map((_) {
                return const CircularProgressIndicator();
              }).toList(),
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: allPlayerIds.map((_) {
              return const CircularProgressIndicator();
            }).toList(),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          final players = snapshot.data!;
          if (orientation == IconsOrientation.vertical) {
            return Column(
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
                      Text(player.name),
                    ],
                  ),
                );
              }).toList(),
            );
          }
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
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: allPlayerIds.map((_) {
            return const Text('Loading...');
          }).toList(),
        );
      },
    );
  }
}
