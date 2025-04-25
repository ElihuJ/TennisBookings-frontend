import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../global_widgets/text/index.dart';
import '../../../../../state/index.dart';
import '../../../../../theme/index.dart';
import '../../../../club/club_details_screen.dart';

class MembershipDetails extends HookConsumerWidget {
  const MembershipDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    final clubsNotifier = ref.read(clubsProvider.notifier);

    final clubs = ref.watch(clubsProvider);

    // * This will execute when refreshing page or loading specific URL directly
    if (clubs.isEmpty) {
      clubsNotifier.loadClubs();
      return const Scaffold(
        body: Center(
          child: Text('Loading clubs...'),
        ),
      );
    }

    final clubsWithMembership = user.memberships.map((membership) => membership.clubId).toList();

    if (clubsWithMembership.isEmpty) {
      return _NoMembershipView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(height: 20),
        const TitleText(
          'Membership Details',
        ),
        const SizedBox(height: 20),
        Flexible(
          child: SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: clubsWithMembership.length,
              itemBuilder: (context, index) {
                final club = clubs.firstWhere((club) => club.id == clubsWithMembership[index]);

                return Center(
                  child: SizedBox(
                    width: 500,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.sports_tennis, color: Theme.of(context).primaryColor, size: 40),
                                const SizedBox(width: 12),
                                Text(
                                  club.name,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Address: ${club.streetAddress}, ${club.suburb}, ${club.city}, ${club.state}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Annual Fee: \$${club.annualFee.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('${ClubDetailsScreen.route}?clubId=${club.id}');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondaryGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('View Club Details'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _NoMembershipView extends StatelessWidget {
  const _NoMembershipView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied,
            size: 100,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 10),
          Text(
            'No Club Memberships',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Looks like you\'re not a member of any club yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
