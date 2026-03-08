import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_helpers/index.dart';
import '../../../global_widgets/index.dart';
import '../../../state/index.dart';
import '../../payments/membership_payment_screen.dart';
import 'card.dart';

double _fontTitleSize = 24.0;

void _navigateToMembershipScreen({required BuildContext context, required Club clubSelected}) {
  Navigator.of(context).pushNamed('${MembershipPaymentScreen.route}?clubId=${clubSelected.id}');
}

class MembershipCard extends HookConsumerWidget {
  final Club clubSelected;

  const MembershipCard({super.key, required this.clubSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isMember = user.memberships.any((membership) => membership.clubId == clubSelected.id);
    final membershipExpiryDate = user.memberships.firstWhereOrNull((membership) => membership.clubId == clubSelected.id)?.expiry;
    final isLoggedIn = user.uid.isNotEmpty;

    return SizedBox(
      width: CardTemplate.cardsWidth,
      child: isLoggedIn
          ? isMember
              ? _MemberContainer(clubSelected: clubSelected, membershipExpiryDate: membershipExpiryDate)
              : _NotMemberContainer(clubSelected: clubSelected)
          : _NotLoggedInContainer(),
    );
  }
}

class _MemberContainer extends StatelessWidget {
  const _MemberContainer({required this.clubSelected, required this.membershipExpiryDate});

  final Club clubSelected;
  final int? membershipExpiryDate;

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
        if (membershipExpiryDate != null)
          PrettyText(
            'Expiry Date: ${prettyDateLocalFromEpoch(membershipExpiryDate!)}',
            style: TextStyle(fontStyle: FontStyle.italic),
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
        ),
      ],
    );
  }
}
