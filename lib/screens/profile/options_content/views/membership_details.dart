import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_helpers/index.dart';
import 'package:tennisbookings/global_widgets/containers/bordered_box.dart';

import '../../../../state/index.dart';

class MembershipDetails extends HookConsumerWidget {
  const MembershipDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    final clubs = ref.read(clubsProvider);

    final homeClub = findByIdOrNull<Club>(clubs, user.homeClubId);

    if (homeClub == null) {
      return BorderedBox(
        width: widthPercent(context, percentage: 80),
        child: Center(
            child: const Text(
          'No home club',
          textAlign: TextAlign.center,
        )),
      );
    }

    return Text(homeClub.name);
  }
}
