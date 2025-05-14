import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../assets/index.dart';
import '../../global_widgets/index.dart';
import '../../state/clubs/index.dart';
import '../login/widgets/containers.dart';
import 'clubs_table.dart';

class FindClubsScreen extends HookConsumerWidget {
  const FindClubsScreen({super.key});
  static const route = 'SelectClub';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsNotifier = ref.read(clubsProvider.notifier);
    final clubs = ref.watch(clubsProvider);

    // * This will execute when refreshing page or loading specific URL directly
    if (clubs.isEmpty) {
      clubsNotifier.loadClubs();
      return const TbScaffold(
        body: Center(
          child: Text('Loading clubs...'),
        ),
      );
    }

    // * remove duplicates from clubs
    List<Club> uniqueClubs = clubs.toSet().toList();
    uniqueClubs.removeWhere((club) => club.enabled == false);

    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: TbScaffold(
          body: ContainerWithBackground(
            imagePath: homeBackgroundPng,
            child: ClubsTable(clubs: uniqueClubs),
          ),
        ),
      ),
    );
  }
}
