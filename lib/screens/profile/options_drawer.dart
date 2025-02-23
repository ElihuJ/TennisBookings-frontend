import 'package:flutter/material.dart';
import 'package:tennisbookings/screens/profile/profile_screen.dart';
import 'package:tennisbookings/theme/index.dart';

class OptionsDrawer extends StatelessWidget {
  const OptionsDrawer({
    super.key,
    required this.toggleSelectedOption,
  });

  final void Function(ProfileOptions option) toggleSelectedOption;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(30.0),
      decoration: BoxDecoration(
        color: AppColors.almostWhite,
        border: Border(
          right: BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: const Text('Profile Details'),
            onTap: () {
              toggleSelectedOption(ProfileOptions.profileDetails);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              toggleSelectedOption(ProfileOptions.settings);
            },
          ),
          ListTile(
            leading: Icon(Icons.card_membership),
            title: const Text('Memberships'),
            onTap: () {
              toggleSelectedOption(ProfileOptions.memberships);
            },
          ),
        ],
      ),
    );
  }
}
