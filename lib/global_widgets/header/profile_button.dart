import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../state/index.dart';
import '../../theme/colors.dart';

class ProfileButton extends HookConsumerWidget {
  const ProfileButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fbNotifier = ref.read(firebaseAuthProvider.notifier);

    return IconButton(
        icon: Icon(
          Icons.person,
          color: AppColors.white,
        ),
        onPressed: () => fbNotifier.logout());
  }
}
