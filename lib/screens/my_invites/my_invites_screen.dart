import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../global_helpers/index.dart';
import '../../global_widgets/index.dart';
import '../../state/index.dart';
import '../../strings/index.dart';
import '../../theme/index.dart';
import '../login/widgets/containers.dart';
import 'widgets/booking_with_invites_container.dart';

class MyInvitesScreen extends HookConsumerWidget {
  const MyInvitesScreen({super.key});

  static const route = 'MyInvites';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isLoggedIn = user.uid.isNotEmpty;

    if (!isLoggedIn) {
      return const NotFoundScreen();
    }

    final bookingsWithInvites = user.bookingsWithPopulatedRequests;

    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: TbScaffold(
          body: ContainerWithBackground(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      _InvitesHero(pendingCount: bookingsWithInvites.length),
                      const SizedBox(height: 24),
                      if (bookingsWithInvites.isEmpty)
                        const _NoInvitesView()
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: bookingsWithInvites.length,
                          itemBuilder: (context, index) {
                            final booking = bookingsWithInvites[index];
                            if (booking.requests.isEmpty) return const SizedBox.shrink();
                            return BookingWithInvites(booking: booking);
                          },
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hero banner ──────────────────────────────────────────────────────────────

class _InvitesHero extends StatelessWidget {
  const _InvitesHero({required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);
    final fontSize = getFontSize(mobileView);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.mail_outline, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.localeString(InvitesStrings.title),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize + 4,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                if (pendingCount > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '$pendingCount pending',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _NoInvitesView extends StatelessWidget {
  const _NoInvitesView();

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);
    final fontSize = getFontSize(mobileView);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, size: 72, color: AppColors.primaryGreen.withValues(alpha: 0.45)),
          const SizedBox(height: 16),
          Text(
            context.localeString(InvitesStrings.noInvitesTitle),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize + 4,
              color: AppColors.darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.localeString(InvitesStrings.noInvitesMessage),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
