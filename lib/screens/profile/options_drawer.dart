import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../state/index.dart';
import '../../theme/index.dart';
import '../home_screen.dart';
import 'profile_screen.dart';

class OptionsDrawer extends HookConsumerWidget {
  const OptionsDrawer({
    super.key,
    required this.toggleSelectedOption,
  });

  final void Function(ProfileOptions option) toggleSelectedOption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fbNotifier = ref.read(firebaseAuthProvider.notifier);
    final clubNotifier = ref.read(clubsProvider.notifier);
    final screenWidth = MediaQuery.of(context).size.width;
    final smallScreen = screenWidth < 600;

    return Container(
      width: smallScreen ? 100 : 300,
      padding: const EdgeInsets.all(30.0),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.5),
        border: Border(
          right: BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: smallScreen ? null : const Text('Profile Details'),
            onTap: () => toggleSelectedOption(ProfileOptions.profileDetails),
          ),
          Divider(color: AppColors.primaryGreen),
          // ListTile(
          //   leading: Icon(Icons.settings),
          //   title: const Text('Settings'),
          //   onTap: () => toggleSelectedOption(ProfileOptions.settings),
          // ),
          // Divider(color: AppColors.primaryGreen),
          ListTile(
            leading: Icon(Icons.card_membership),
            title: smallScreen ? null : const Text('Memberships'),
            onTap: () => toggleSelectedOption(ProfileOptions.memberships),
          ),
          Divider(color: AppColors.primaryGreen),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: smallScreen ? null : const Text('Logout'),
            onTap: () async {
              await fbNotifier.logout();
              clubNotifier.clearPrivateBookings();
              if (context.mounted) {
                Navigator.of(context).pushNamed(HomeScreen.route);
              }
            },
          ),
        ],
      ),
    );
  }
}
