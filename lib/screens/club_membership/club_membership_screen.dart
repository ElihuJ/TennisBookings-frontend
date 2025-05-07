import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_helpers/index.dart';
import 'package:tennisbookings/screens/club_membership/stripe_payment_widget.dart';

import '../../cloud_functions/index.dart';
import '../../global_widgets/header/header.dart';
import '../../global_widgets/index.dart';
import '../../routes/index.dart';
import '../../state/index.dart';

class ClubMembershipScreen extends HookConsumerWidget {
  const ClubMembershipScreen({super.key, required this.clubSelectedQueryParams});

  final ClubSelectedQueryParams clubSelectedQueryParams;
  static const String route = 'ClubMembership';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubs = ref.watch(clubsProvider);
    final user = ref.watch(userProvider);
    final clubsNotifier = ref.read(clubsProvider.notifier);

    final clubSelected = clubs.firstWhereOrNull((club) => club.id == clubSelectedQueryParams.clubId);

    // * This will execute when refreshing page or loading specific URL directly
    if (clubs.isEmpty) {
      clubsNotifier.loadClubs();
      return const LoadingScreen(message: 'Loading clubs...');
    }

    if (clubSelected == null) {
      return const NotFoundScreen(
        message: 'The club you are looking for does not exist.',
      );
    }

    final cloudFunctions = ref.read(cloudFunctionsProvider.notifier);
    final alreadyMember = user.memberships.any((membership) => membership.clubId == clubSelected.id);

    if (alreadyMember) {
      return NotFoundScreen(message: 'You are already a member of this club. Please check your membership details in the profile section.');
    }

    return _PaymentView(cloudFunctions: cloudFunctions, clubSelected: clubSelected);
  }
}

class _PaymentView extends StatelessWidget {
  const _PaymentView({
    required this.cloudFunctions,
    required this.clubSelected,
  });

  final CloudFunctionsNotifier cloudFunctions;
  final Club clubSelected;

  @override
  Widget build(BuildContext context) {
    return EventfulWidget(
      child: Scaffold(
        appBar: Header(),
        body: Container(
          padding: const EdgeInsets.all(20.0),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: cloudFunctions.getPaymentIntent(clubSelected.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  snapshot.error?.tbLogger('Error loading club payment data');
                  return const Center(
                    child: Text('Error loading club payment data'),
                  );
                }
                final clientSecret = snapshot.data?.data;

                if (clientSecret == null) {
                  'Client secret is null'.tbLogger();
                  return const Center(
                    child: Text('Error loading club payment data'),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  spacing: 50,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(clubSelected.clubLogoUrl),
                      backgroundColor: Colors.grey[200],
                    ),
                    StripePaymentForm(
                      clientSecret: clientSecret,
                      club: clubSelected,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
