import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/index.dart';
import '../../screens/profile/profile_screen.dart';
import '../../state/index.dart';
import '../index.dart';

class ProfileButton extends HookConsumerWidget {
  const ProfileButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    final player = ConfirmedPlayerData(id: user.uid, name: user.name, utrVerified: user.utrVerified, photoUrl: user.photoUrl);

    return IconButton(
      icon: PlayerIcon(player: player),
      onPressed: () {
        Navigator.of(context).pushNamed(ProfileScreen.route);
      },
    );
  }
}
