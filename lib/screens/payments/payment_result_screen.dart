import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web/web.dart' as web;

import '../../global_widgets/index.dart';
import '../../routes/index.dart';
import '../../strings/index.dart';
import '../../theme/colors.dart';
import '../calendar/calendar_screen.dart';
import '../login/widgets/containers.dart';
import 'payment_widgets.dart';

class PaymentResultScreen extends StatefulHookConsumerWidget {
  const PaymentResultScreen({super.key, required this.params});

  final StripePaymentQueryParams params;
  static const String route = 'PaymentResult';

  @override
  ConsumerState<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends ConsumerState<PaymentResultScreen> {
  @override
  void initState() {
    super.initState();
    final history = web.window.history;
    history.replaceState(history.state, '', '#${PaymentResultScreen.route}');
  }

  @override
  Widget build(BuildContext context) {
    final hasAllData = widget.params.paymentIntent.isNotEmpty && widget.params.paymentIntentClientSecret.isNotEmpty;

    if (!hasAllData) {
      return NotFoundScreen();
    }
    if (widget.params.redirectStatus != StripePaymentRedirectStatus.succeeded) {
      return _PaymentFailed();
    }

    return _PaymentSuccessful(params: widget.params);
  }
}

class _PaymentSuccessful extends StatelessWidget {
  const _PaymentSuccessful({required this.params});

  final StripePaymentQueryParams params;

  @override
  Widget build(BuildContext context) {
    return TbScaffold(
      body: ContainerWithBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PaymentResultHeader(
                      icon: Icons.check_circle_outline,
                      title: context.localeString(PaymentStrings.successfulTitle),
                      isSuccess: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.localeString(PaymentStrings.successfulMessage),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textBody, fontSize: 14, height: 1.6),
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pushNamed(
                              '${CalendarScreen.route}?clubId=${params.clubId}&courtId=${params.courtId}',
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            child: Text(context.localeString(PaymentStrings.goToCalendar)),
                          ),
                        ],
                      ),
                    ),
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

class _PaymentFailed extends StatelessWidget {
  const _PaymentFailed();

  @override
  Widget build(BuildContext context) {
    return TbScaffold(
      body: ContainerWithBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PaymentResultHeader(
                      icon: Icons.cancel_outlined,
                      title: context.localeString(PaymentStrings.failedTitle),
                      isSuccess: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.localeString(PaymentStrings.failedSupport),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textBody, fontSize: 14, height: 1.6),
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.dangerRed,
                              side: const BorderSide(color: AppColors.dangerRed),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            child: Text(context.localeString(GeneralStrings.goBack)),
                          ),
                        ],
                      ),
                    ),
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
