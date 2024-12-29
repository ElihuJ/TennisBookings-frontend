import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_helpers/index.dart';

import '../../global_widgets/header/index.dart';
import '../../routes/index.dart';
import '../../state/clubs/index.dart';

class ClubSelectedScreen extends HookConsumerWidget {
  const ClubSelectedScreen({super.key, required this.clubSelectedQueryParams});

  final ClubSelectedQueryParams clubSelectedQueryParams;
  static const String route = 'ClubSchedule';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubs = ref.watch(clubsProvider);

    // * This will execute when refreshing page or loading specific URL directly
    if (clubs.isEmpty) {
      final clubsNotifier = ref.read(clubsProvider.notifier);
      clubsNotifier.loadClubs();
    }

    final clubSelected = findByIdOrNull<Club>(clubs, clubSelectedQueryParams.clubId);

    if (clubSelected == null) {
      return const Scaffold(
        appBar: Header(),
        body: Center(
          child: Text('Club not found'),
        ),
      );
    }

    return Scaffold(
      appBar: Header(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(clubSelected.name)],
        ),
      ),
    );
  }
}
