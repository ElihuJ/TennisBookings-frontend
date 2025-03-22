import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/screens/home_screen.dart';
import 'package:tennisbookings/screens/profile/profile_screen.dart';
import 'package:tennisbookings/state/index.dart';
import 'package:tennisbookings/theme/index.dart';

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
    return Container(
      width: 250,
      padding: const EdgeInsets.all(30.0),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.5),
        border: Border(
          right: BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: const Text('Profile Details'),
            onTap: () => toggleSelectedOption(ProfileOptions.profileDetails),
          ),
          Divider(color: AppColors.primaryGreen),
          ListTile(
            leading: Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => toggleSelectedOption(ProfileOptions.settings),
          ),
          Divider(color: AppColors.primaryGreen),
          ListTile(
            leading: Icon(Icons.card_membership),
            title: const Text('Memberships'),
            onTap: () => toggleSelectedOption(ProfileOptions.memberships),
          ),
          Divider(color: AppColors.primaryGreen),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () async {
              await fbNotifier.logout();
              clubNotifier.clearPrivateBookings();
              if (context.mounted) Navigator.of(context).pushNamed(HomeScreen.route);
            },
          ),
        ],
      ),
    );
  }
}
