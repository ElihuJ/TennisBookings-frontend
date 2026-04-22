import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_helpers/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../strings/index.dart';
import '../../../theme/index.dart';
import 'request_container.dart';

class BookingWithInvites extends HookConsumerWidget {
  const BookingWithInvites({super.key, required this.booking});

  final BookingWithPopulatedRequest booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsNotifier = ref.read(clubsProvider.notifier);

    final namesFuture = Future.wait([
      clubsNotifier.getClubName(clubId: booking.clubId),
      clubsNotifier.getCourtName(clubId: booking.clubId, courtId: booking.courtId),
    ]);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FutureBuilder<List<String>>(
        future: namesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.antiAlias,
              child: const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
              ),
            );
          }

          final clubName = snapshot.data?[0] ?? 'Unknown Club';
          final courtName = snapshot.data?[1] ?? 'Unknown Court';

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CardHero(title: booking.title, clubName: clubName),
                _CardDetails(booking: booking, clubName: clubName, courtName: courtName),
                if (booking.requests.isNotEmpty) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  const SizedBox(height: 8),
                  ...booking.requests.map(
                    (request) => RequestContainer(request: request, booking: booking),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Card hero ────────────────────────────────────────────────────────────────

class _CardHero extends StatelessWidget {
  const _CardHero({required this.title, required this.clubName});

  final String title;
  final String clubName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.event_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  clubName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card details ─────────────────────────────────────────────────────────────

class _CardDetails extends StatelessWidget {
  const _CardDetails({
    required this.booking,
    required this.clubName,
    required this.courtName,
  });

  final BookingWithPopulatedRequest booking;
  final String clubName;
  final String courtName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.sports_tennis_outlined,
            label: context.localeString(InvitesStrings.court),
            value: courtName,
          ),
          const _Divider(),
          _InfoRow(
            icon: Icons.schedule_outlined,
            label: context.localeString(InvitesStrings.from),
            value: prettyDateLocalWithTimeFromEpoch(booking.startTime),
          ),
          const _Divider(),
          _InfoRow(
            icon: Icons.timer_off_outlined,
            label: context.localeString(InvitesStrings.to),
            value: prettyDateLocalWithTimeFromEpoch(booking.endTime),
          ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(height: 1, indent: 52, endIndent: 16);
}
