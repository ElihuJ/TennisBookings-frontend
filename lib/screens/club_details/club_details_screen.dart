import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/screens/club_details/widgets/club_details_card.dart';
import 'package:tennisbookings/screens/club_details/widgets/contact_card.dart';
import 'package:tennisbookings/screens/club_details/widgets/membership_card.dart';

import '../../global_widgets/header/header.dart';
import '../../global_widgets/index.dart';
import '../../routes/index.dart';
import '../../state/index.dart';
import 'widgets/title_card.dart';

final _space = SizedBox(height: 20);

class ClubDetailsScreen extends HookConsumerWidget {
  const ClubDetailsScreen({super.key, required this.clubSelectedQueryParams});

  final ClubSelectedQueryParams clubSelectedQueryParams;

  static const String route = 'ClubDetails';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubs = ref.watch(clubsProvider);
    final clubsNotifier = ref.read(clubsProvider.notifier);

    final clubSelected = clubs.firstWhereOrNull((club) => club.id == clubSelectedQueryParams.clubId);

    // * This will execute when refreshing page or loading specific URL directly
    if (clubs.isEmpty) {
      clubsNotifier.loadClubs();
      return const Scaffold(
        body: Center(
          child: Text('Loading clubs...'),
        ),
      );
    }

    if (clubSelected == null) {
      return const NotFoundScreen(
        message: 'The club you are looking for does not exist.',
      );
    }

    return Scaffold(
      appBar: Header(),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(clubSelected.clubLogoUrl),
                backgroundColor: Colors.grey[200],
              ),
              _space,
              MembershipCard(clubSelected: clubSelected),
              _space,
              ClubTitleCard(clubSelected: clubSelected),
              _space,
              ClubDetailsCard(clubSelected: clubSelected),
              _space,
              ContactCard(clubSelected: clubSelected),
            ],
          ),
        ),
      ),
    );
  }
}
