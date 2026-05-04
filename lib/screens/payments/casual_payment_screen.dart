import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../cloud_functions/index.dart';
import '../../global_helpers/index.dart';
import '../../global_widgets/index.dart';
import '../../models/index.dart';
import '../../state/index.dart';
import '../../strings/index.dart';
import '../login/widgets/containers.dart';
import 'casual_payment_form.dart';
import 'payment_widgets.dart';

class CasualPaymentScreen extends HookConsumerWidget {
  const CasualPaymentScreen({super.key, required this.booking});

  final Booking booking;
  static const String route = 'CasualPayment';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PaymentView(booking: booking);
  }
}

class _PaymentView extends StatefulHookConsumerWidget {
  const _PaymentView({required this.booking});

  final Booking booking;

  @override
  ConsumerState<_PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends ConsumerState<_PaymentView> {
  // late final ensures the future is created exactly once; keyboard-triggered
  // rebuilds reuse the same future so FutureBuilder never restarts.
  late final _paymentIntentFuture = ref
      .read(cloudFunctionsProvider.notifier)
      .getCasualPaymentIntent(booking: widget.booking);

  @override
  Widget build(BuildContext context) {
    final clubs = ref.watch(clubsProvider);
    final clubSelected = clubs.firstWhereOrNull((club) => club.id == widget.booking.clubId);

    if (clubSelected == null) {
      return NotFoundScreen(message: context.localeString(PaymentStrings.clubNotFound));
    }

    final court = clubSelected.courts.firstWhereOrNull((court) => court.id == widget.booking.courtId);

    if (court == null) {
      return NotFoundScreen(message: context.localeString(PaymentStrings.courtNotFound));
    }

    final mobileView = isMobile(context);

    Widget skeletonCard() => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: PaymentCardSkeleton(
              isMobile: mobileView,
              header: PaymentCardHeader(
                logoUrl: clubSelected.clubLogoUrl,
                title: widget.booking.title,
                subtitle: context.localeString(PaymentStrings.casualTitle),
              ),
            ),
          ),
        );

    return EventfulWidget(
      child: TbScaffold(
        body: ContainerWithBackground(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: FutureBuilder(
                future: _paymentIntentFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return skeletonCard();
                  }
                  if (snapshot.hasError || snapshot.data?.data == null) {
                    snapshot.error?.tbLogger('Error loading club payment data');
                    return NotFoundScreen(
                      message: context.localeString(PaymentStrings.errorLoadingCasual),
                      noScaffold: true,
                    );
                  }

                  final response = snapshot.data!.data!;

                  return StripeSettingsLoader(
                    stripeAccountId: response.clubStripeAccountId,
                    skeleton: skeletonCard(),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                        child: CasualPaymentForm(
                          clientSecret: response.clientSecret,
                          club: clubSelected,
                          booking: widget.booking,
                          court: court,
                        ),
                      ),
                    ),
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
