import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../assets/index.dart';
import '../../global_widgets/eventful/eventful.dart';
import '../../global_widgets/header/index.dart';
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
      return const Scaffold(
        body: Center(
          child: Text('Loading clubs...'),
        ),
      );
    }

    // * remove duplicates from clubs
    final uniqueClubs = clubs.toSet().toList();

    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          appBar: Header(),
          body: ContainerWithBackground(
            imagePath: homeBackgroundPng,
            child: ClubsTable(clubs: uniqueClubs),
          ),
        ),
      ),
    );
  }
}
