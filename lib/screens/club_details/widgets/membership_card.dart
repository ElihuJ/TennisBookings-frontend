import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_widgets/index.dart';
import '../../../state/index.dart';
import '../../club_membership/club_membership_screen.dart';
import 'card.dart';

double _fontTitleSize = 24.0;
double _fontSize = 16.0;

void _navigateToMembershipScreen({required BuildContext context, required Club clubSelected}) {
  Navigator.of(context).pushNamed('${ClubMembershipScreen.route}?clubId=${clubSelected.id}');
}

class MembershipCard extends HookConsumerWidget {
  final Club clubSelected;

  const MembershipCard({super.key, required this.clubSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    // ! TODO: Uncomment this when userProvider is implemented
    // final isMember = user.memberships.any((membership) => membership.clubId == clubSelected.id);
    final isLoggedIn = user.uid.isNotEmpty;
    final isMember = false;
    // final isLoggedIn = false;

    return SizedBox(
      width: CardTemplate.cardsWidth,
      child: isLoggedIn
          ? isMember
              ? _MemberContainer(clubSelected: clubSelected)
              : _NotMemberContainer(clubSelected: clubSelected)
          : _NotLoggedInContainer(),
    );
  }
}

class _MemberContainer extends StatelessWidget {
  const _MemberContainer({required this.clubSelected});

  final Club clubSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PrettyText(
          'You are a Member ⭐️',
          fontSize: _fontTitleSize,
          textAlign: TextAlign.center,
        ),
        const Divider(),
        TbTextButton(
          text: 'Manage Membership',
          fontSize: _fontSize,
          onPressed: () {
            _navigateToMembershipScreen(context: context, clubSelected: clubSelected);
          },
        ),
      ],
    );
  }
}

class _NotMemberContainer extends StatelessWidget {
  const _NotMemberContainer({required this.clubSelected});

  final Club clubSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PrettyText(
          'You are not a member',
          fontSize: _fontTitleSize,
          textAlign: TextAlign.center,
        ),
        const Divider(),
        TbTextButton(
          text: 'Join this club',
          onPressed: () {
            _navigateToMembershipScreen(context: context, clubSelected: clubSelected);
          },
        ),
      ],
    );
  }
}

class _NotLoggedInContainer extends StatelessWidget {
  const _NotLoggedInContainer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PrettyText(
          'Login for more details',
          fontSize: _fontTitleSize,
          textAlign: TextAlign.center,
        ),
        const Divider(),
        PrettyText(
          'You need to login to see membership details',
          fontSize: _fontSize,
        ),
      ],
    );
  }
}
