import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../cloud_functions/index.dart';
import '../../global_helpers/index.dart';
import '../../global_widgets/index.dart';
import '../../routes/index.dart';
import '../../state/index.dart';
import '../../strings/index.dart';
import '../login/widgets/containers.dart';
import 'membership_payment_form.dart';
import 'payment_widgets.dart';

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
      return LoadingScreen(message: context.localeString(PaymentStrings.loadingData));
    }

    if (clubSelected == null) {
      return NotFoundScreen(message: context.localeString(PaymentStrings.clubNotFound));
    }

    final alreadyMember = user.memberships.any((membership) => membership.clubId == clubSelected.id);

    if (alreadyMember) {
      return NotFoundScreen(message: context.localeString(PaymentStrings.alreadyMember));
    }

    return _PaymentView(clubSelected: clubSelected);
  }
}

class _PaymentView extends StatefulHookConsumerWidget {
  const _PaymentView({required this.clubSelected});

  final Club clubSelected;

  @override
  ConsumerState<_PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends ConsumerState<_PaymentView> {
  // late final ensures the future is created exactly once; keyboard-triggered
  // rebuilds reuse the same future so FutureBuilder never restarts.
  late final _paymentIntentFuture = ref
      .read(cloudFunctionsProvider.notifier)
      .getMembershipPaymentIntent(clubId: widget.clubSelected.id);

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);

    Widget skeletonCard() => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: PaymentCardSkeleton(
              isMobile: mobileView,
              header: PaymentCardHeader(
                logoUrl: widget.clubSelected.clubLogoUrl,
                title: widget.clubSelected.name,
                subtitle: context.localeString(PaymentStrings.membershipTitle),
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
                      message: context.localeString(PaymentStrings.errorLoading),
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
                        child: MembershipPaymentForm(
                          clientSecret: response.clientSecret,
                          club: widget.clubSelected,
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
