import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../global_helpers/index.dart';
import '../../global_widgets/index.dart';
import '../../routes/index.dart';
import '../../state/index.dart';
import '../../strings/index.dart';
import '../../theme/index.dart';
import '../login/widgets/containers.dart';
import '../payments/membership_payment_screen.dart';

class ClubDetailsScreen extends HookConsumerWidget {
  const ClubDetailsScreen({super.key, required this.clubSelectedQueryParams});

  final ClubSelectedQueryParams clubSelectedQueryParams;

  static const String route = 'ClubDetails';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubs = ref.watch(clubsProvider);
    final clubsNotifier = ref.read(clubsProvider.notifier);

    final clubSelected = clubs.firstWhereOrNull((club) => club.id == clubSelectedQueryParams.clubId);

    if (clubs.isEmpty) {
      clubsNotifier.loadClubs();
      return Scaffold(
        body: Center(child: PrettyText(context.localeString(ClubsStrings.loading))),
      );
    }

    if (clubSelected == null) {
      return NotFoundScreen(message: context.localeString(PaymentStrings.clubNotFound));
    }

    return TbScaffold(
      body: ContainerWithBackground(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 28),
                    _ClubHero(club: clubSelected),
                    const SizedBox(height: 20),
                    _MembershipCard(club: clubSelected),
                    const SizedBox(height: 20),
                    _DetailsCard(club: clubSelected),
                    const SizedBox(height: 20),
                    _ContactCard(club: clubSelected),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────

class _ClubHero extends StatelessWidget {
  const _ClubHero({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2.5),
              color: Colors.white.withValues(alpha: 0.1),
            ),
            child: ClipOval(
              child: Image.network(
                club.clubLogoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.sports_tennis, color: Colors.white, size: 36),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            club.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              final url = Uri.encodeFull(
                'https://www.google.com/maps/search/?api=1&query=${club.streetAddress}, ${club.suburb}, ${club.city}, ${club.state}, ${club.postcode}',
              );
              launchUrl(Uri.parse(url));
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: Colors.white.withValues(alpha: 0.8)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${club.streetAddress}, ${club.suburb}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Membership card ──────────────────────────────────────────────────────────

class _MembershipCard extends ConsumerWidget {
  const _MembershipCard({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isMember = user.memberships.any((m) => m.clubId == club.id);
    final expiry = user.memberships.firstWhereOrNull((m) => m.clubId == club.id)?.expiry;
    final isLoggedIn = user.uid.isNotEmpty;

    if (!isLoggedIn) {
      return _InfoBanner(
        icon: Icons.lock_outline,
        title: context.localeString(ClubsStrings.loginForDetails),
        subtitle: context.localeString(ClubsStrings.loginForDetailsMsg),
        color: AppColors.grey,
      );
    }

    if (isMember) {
      return _InfoBanner(
        icon: Icons.verified_outlined,
        title: context.localeString(ClubsStrings.youAreAMember),
        subtitle: expiry != null ? '${context.localeString(ClubsStrings.expiryDate)} ${prettyDateLocalFromEpoch(expiry)}' : null,
        color: AppColors.gold,
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.card_membership_outlined, size: 18, color: AppColors.primaryGreen),
                const SizedBox(width: 10),
                Text(
                  context.localeString(ClubsStrings.notAMember),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('${MembershipPaymentScreen.route}?clubId=${club.id}'),
              icon: const Icon(Icons.add, size: 16),
              label: Text(context.localeString(ClubsStrings.joinThisClub)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.95)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: color)),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.blueGrey)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Details card ─────────────────────────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[
      (Icons.sports_tennis_outlined, context.localeString(ClubsStrings.hardCourts), '${club.hardCourts}'),
      (Icons.landscape_outlined, context.localeString(ClubsStrings.clayCourts), '${club.clayCourts}'),
      (Icons.grass_outlined, context.localeString(ClubsStrings.grassCourts), '${club.grassCourts}'),
      (Icons.sports_outlined, context.localeString(ClubsStrings.otherCourts), '${club.otherSurfaceCourts}'),
      (
        Icons.public_outlined,
        context.localeString(ClubsStrings.publicBookingsAllowed),
        club.onlyMembers ? context.localeString(GeneralStrings.no) : context.localeString(GeneralStrings.yes)
      ),
      (Icons.payments_outlined, context.localeString(ClubsStrings.annualMembershipFee), '\$${club.annualFee.toStringAsFixed(2)}'),
      if (club.casualFee != null)
        (Icons.receipt_outlined, context.localeString(ClubsStrings.casualBooking), '\$${club.casualFee!.toStringAsFixed(2)}'),
      (Icons.people_outlined, context.localeString(ClubsStrings.totalMembers), '${club.memberIds.length}'),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            _CardSectionHeader(
              icon: Icons.info_outline,
              label: context.localeString(ClubsStrings.detailsTitle),
            ),
            const Divider(height: 1),
            ...rows.mapIndexed((i, row) => Column(
                  children: [
                    _InfoRow(icon: row.$1, label: row.$2, value: row.$3),
                    if (i < rows.length - 1) const Divider(height: 1, indent: 52, endIndent: 16),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Contact card ─────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            _CardSectionHeader(
              icon: Icons.contacts_outlined,
              label: context.localeString(ClubsStrings.contactTitle),
            ),
            const Divider(height: 1),
            _InfoRow(
              icon: Icons.email_outlined,
              label: context.localeString(ClubsStrings.contactEmail),
              value: club.contactEmail ?? '—',
            ),
            const Divider(height: 1, indent: 52, endIndent: 16),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: context.localeString(ClubsStrings.contactPhone),
              value: club.contactPhone ?? '—',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _CardSectionHeader extends StatelessWidget {
  const _CardSectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
