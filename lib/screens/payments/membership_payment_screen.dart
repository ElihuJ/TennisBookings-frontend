import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' show Stripe;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/assets/index.dart';

import '../../cloud_functions/index.dart';
import '../../global_helpers/index.dart';
import '../../global_widgets/index.dart';
import '../../routes/index.dart';
import '../../state/index.dart';
import '../../theme/colors.dart';
import '../login/widgets/containers.dart';
import 'membership_payment_form.dart';

class MembershipPaymentScreen extends HookConsumerWidget {
  const MembershipPaymentScreen({super.key, required this.clubSelectedQueryParams});

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
      return const LoadingScreen(message: 'Loading Payment Data...');
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
      child: TbScaffold(
        body: ContainerWithBackground(
          imagePath: homeBackgroundPng,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: FutureBuilder(
                future: cloudFunctions.getMembershipPaymentIntent(clubId: clubSelected.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingScreen(
                      message: 'Loading payment data...',
                      noScaffold: true,
                    );
                  }
                  if (snapshot.hasError || snapshot.data?.data == null) {
                    snapshot.error?.tbLogger('Error loading club payment data');
                    return const NotFoundScreen(
                      message: 'Error loading club payment data',
                      noScaffold: true,
                    );
                  }

                  final response = snapshot.data?.data;
                  if (response == null) {
                    'Client secret is null'.tbLogger();
                    return const NotFoundScreen(
                      message: 'Error loading club payment data',
                      noScaffold: true,
                    );
                  }

                  final clientSecret = response.clientSecret;
                  final clubStripeAccountId = response.clubStripeAccountId;

                  Stripe.stripeAccountId = clubStripeAccountId;

                  return FutureBuilder(
                    future: Stripe.instance.applySettings(),
                    builder: (context, asyncSnapshot) {
                      if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                        return LoadingScreen(
                          message: 'Initializing payment form...',
                          noScaffold: true,
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          spacing: 50,
                          children: [
                            CircleAvatar(
                                radius: 60, backgroundImage: NetworkImage(clubSelected.clubLogoUrl), backgroundColor: AppColors.white),
                            MembershipPaymentForm(
                              clientSecret: clientSecret,
                              club: clubSelected,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
