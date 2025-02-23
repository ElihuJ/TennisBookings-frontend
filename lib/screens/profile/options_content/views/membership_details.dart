import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_helpers/logs.dart';

import '../../../../state/index.dart';

class MembershipDetails extends HookConsumerWidget {
  const MembershipDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final clubs = ref.watch(clubsProvider);
    final spacer = const SizedBox(height: 26.0);

    final homeClub = clubs.where((club) => club.id == user.homeClubId).first;

    homeClub.tbLogger('Memberships build');

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(homeClub.name),
              spacer,
            ],
          ),
        ),
      ),
    );
  }
}
