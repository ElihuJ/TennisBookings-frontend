import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_widgets/index.dart';
import '../profile_screen.dart';
import 'views/membership_details/membership_details.dart';
import 'views/profile_details/profile_details.dart';
import 'views/settings.dart';

class OptionsContent extends StatefulHookConsumerWidget {
  const OptionsContent({
    super.key,
    required this.selectedOption,
  });

  final ProfileOptions selectedOption;

  @override
  ConsumerState<OptionsContent> createState() => _OptionsContentState();
}

class _OptionsContentState extends ConsumerState<OptionsContent> {
  @override
  Widget build(BuildContext context) {
    if (widget.selectedOption == ProfileOptions.profileDetails) {
      return const ProfileDetails();
    }
    if (widget.selectedOption == ProfileOptions.settings) {
      return const SettingsContent();
    }
    if (widget.selectedOption == ProfileOptions.memberships) {
      return const MembershipDetails();
    }
    return const NotFoundScreen();
  }
}
