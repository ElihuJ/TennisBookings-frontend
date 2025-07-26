import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../screens/my_invites/my_invites_screen.dart';
import '../../state/index.dart';
import '../index.dart';

class InvitesButtonHeader extends StatefulHookConsumerWidget {
  const InvitesButtonHeader({
    super.key,
  });

  @override
  ConsumerState<InvitesButtonHeader> createState() => _InvitesButtonHeaderState();
}

class _InvitesButtonHeaderState extends ConsumerState<InvitesButtonHeader> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    final inviteCount = user.bookingsWithPopulatedRequests.fold(0, (sum, booking) => sum + booking.requests.length);

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        TbClickableText(
          text: 'MY INVITES',
          onPressed: () => Navigator.of(context).pushNamed(MyInvitesScreen.route),
        ),
        if (inviteCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 15,
                minHeight: 15,
              ),
              child: PrettyText(
                '$inviteCount',
                color: Colors.white,
                fontSize: 10,
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
