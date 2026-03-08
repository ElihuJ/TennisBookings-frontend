import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' show Stripe;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../assets/index.dart';
import '../../cloud_functions/index.dart';
import '../../global_helpers/index.dart';
import '../../global_widgets/index.dart';
import '../../models/index.dart';
import '../../state/index.dart';
import '../../theme/colors.dart';
import '../login/widgets/containers.dart';
import 'casual_payment_form.dart';

class CasualPaymentScreen extends HookConsumerWidget {
  const CasualPaymentScreen({super.key, required this.booking});

  final Booking booking;
  static const String route = 'CasualPayment';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PaymentView(booking: booking);
  }
}

class _PaymentView extends HookConsumerWidget {
  const _PaymentView({
    required this.booking,
  });

  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudFunctions = ref.read(cloudFunctionsProvider.notifier);
    final clubs = ref.watch(clubsProvider);
    final clubSelected = clubs.firstWhereOrNull((club) => club.id == booking.clubId);

    if (clubSelected == null) {
      return const NotFoundScreen(
        message: 'The club you are looking for does not exist.',
      );
    }

    final court = clubSelected.courts.firstWhereOrNull((court) => court.id == booking.courtId);

    if (court == null) {
      return const NotFoundScreen(
        message: 'The court you are looking for does not exist.',
      );
    }

    return EventfulWidget(
      child: TbScaffold(
        body: ContainerWithBackground(
          imagePath: homeBackgroundPng,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: FutureBuilder(
                future: cloudFunctions.getCasualPaymentIntent(booking: booking),
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
                      message: 'Error loading casual payment data',
                      noScaffold: true,
                    );
                  }

                  final response = snapshot.data?.data;
                  if (response == null) {
                    'Client secret is null'.tbLogger();
                    return const NotFoundScreen(
                      message: 'Error loading casual payment data',
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
                            CasualPaymentForm(
                              clientSecret: clientSecret,
                              club: clubSelected,
                              booking: booking,
                              court: court,
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
