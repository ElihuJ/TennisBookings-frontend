import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../global_widgets/index.dart';
import '../../state/index.dart';
import '../login/widgets/containers.dart';
import 'options_content/options_content.dart';
import 'options_drawer.dart';

class ProfileScreen extends StatefulHookConsumerWidget {
  const ProfileScreen({super.key});

  static const route = 'Profile';

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ProfileOptions _selectedOption = ProfileOptions.profileDetails;

  void toggleSelectedOption(ProfileOptions option) {
    setState(() {
      _selectedOption = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isLoggedIn = user.uid.isNotEmpty;

    if (!isLoggedIn) {
      return const NotFoundScreen();
    }

    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: TbScaffold(
          body: ContainerWithBackground(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OptionsDrawer(
                  toggleSelectedOption: toggleSelectedOption,
                  selectedOption: _selectedOption,
                ),
                OptionsContent(selectedOption: _selectedOption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum ProfileOptions {
  profileDetails,
  memberships,
  myBookings,
}
