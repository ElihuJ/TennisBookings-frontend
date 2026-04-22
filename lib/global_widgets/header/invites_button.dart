import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../screens/my_invites/my_invites_screen.dart';
import '../../state/index.dart';
import '../../strings/index.dart';
import '../../theme/index.dart';

class InvitesButtonHeader extends StatefulHookConsumerWidget {
  const InvitesButtonHeader({super.key});

  @override
  ConsumerState<InvitesButtonHeader> createState() => _InvitesButtonHeaderState();
}

class _InvitesButtonHeaderState extends ConsumerState<InvitesButtonHeader> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final inviteCount = user.bookingsWithPopulatedRequests
        .fold(0, (sum, booking) => sum + booking.requests.length);

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed(MyInvitesScreen.route),
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            overlayColor: Colors.white.withValues(alpha: 0.12),
          ),
          child: Text(
            context.localeString(GeneralStrings.headerMyInvites),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
        ),
        if (inviteCount > 0)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '$inviteCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
