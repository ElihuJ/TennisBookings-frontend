import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../global_helpers/index.dart';
import '../../../../../global_widgets/index.dart';
import '../../../../../state/index.dart';
import '../../../../../strings/index.dart';
import '../../../../../theme/index.dart';
import '../../../../club_details/club_details_screen.dart';

class MembershipDetails extends HookConsumerWidget {
  const MembershipDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    final clubsNotifier = ref.read(clubsProvider.notifier);
    final clubs = ref.watch(clubsProvider);
    final mobileView = isMobile(context);
    final fontSize = getFontSize(mobileView);

    if (clubs.isEmpty) {
      clubsNotifier.loadClubs();
      return LoadingScreen(message: context.localeString(ClubsStrings.loading));
    }

    final clubsWithMembership = user.memberships.map((m) => m.clubId).toList();

    if (clubsWithMembership.isEmpty) {
      return _NoMembershipView();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Page title ──
              PrettyText(
                context.localeString(ProfileStrings.membershipDetailsTitle),
                style: TextStyle(
                  fontSize: fontSize + 4,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ...clubsWithMembership.map((clubId) {
                final club = clubs.firstWhere((c) => c.id == clubId);
                final membership = user.memberships.firstWhere((m) => m.clubId == club.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _MembershipCard(club: club, expiry: membership.expiry),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Membership card ──────────────────────────────────────────────────────────

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.club, required this.expiry});

  final Club club;
  final int expiry;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHero(club: club),
          _CardDetails(club: club, expiry: expiry),
        ],
      ),
    );
  }
}

class _CardHero extends StatelessWidget {
  const _CardHero({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          // Club logo
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
            ),
            child: ClipOval(
              child: club.clubLogoUrl.isNotEmpty
                  ? Image.network(club.clubLogoUrl, fit: BoxFit.cover)
                  : Container(
                      color: Colors.white.withValues(alpha: 0.15),
                      child: const Icon(Icons.sports_tennis, color: Colors.white, size: 28),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          // Club name + member badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                _MemberBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberBadge extends StatelessWidget {
  const _MemberBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 13, color: Colors.yellowAccent),
          const SizedBox(width: 5),
          Text(
            context.localeString(ClubsStrings.youAreAMember),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardDetails extends StatelessWidget {
  const _CardDetails({required this.club, required this.expiry});

  final Club club;
  final int expiry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: context.localeString(ProfileStrings.membershipAddress),
            value: '${club.streetAddress}, ${club.suburb}',
          ),
          const _Divider(),
          _InfoRow(
            icon: Icons.attach_money_outlined,
            label: context.localeString(ProfileStrings.membershipAnnualFee),
            value: '\$${club.annualFee.toStringAsFixed(2)}',
          ),
          const _Divider(),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: context.localeString(ProfileStrings.membershipExpiry),
            value: prettyDateLocalFromEpoch(expiry),
            valueStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('${ClubDetailsScreen.route}?clubId=${club.id}'),
                  icon: const Icon(Icons.arrow_forward_outlined, size: 16),
                  label: Text(context.localeString(ProfileStrings.viewClubDetails)),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primaryGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
          ),
          Flexible(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(height: 1, indent: 52, endIndent: 16);
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _NoMembershipView extends StatelessWidget {
  const _NoMembershipView();

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);
    final fontSize = getFontSize(mobileView);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.card_membership_outlined, size: 90, color: AppColors.primaryGreen.withValues(alpha: 0.45)),
          const SizedBox(height: 16),
          PrettyText(
            context.localeString(ProfileStrings.noMemberships),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize + 6,
              color: AppColors.darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          PrettyText(
            context.localeString(ProfileStrings.noMembershipsMsg),
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
