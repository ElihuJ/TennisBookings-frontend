import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web/web.dart' as web;

import '../../global_widgets/index.dart';
import '../../routes/index.dart';
import '../../strings/index.dart';
import '../../theme/index.dart';
import '../calendar/calendar_screen.dart';

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

  String getPaymentStatus(StripePaymentRedirectStatus status) {
    switch (status) {
      case StripePaymentRedirectStatus.succeeded:
        return context.localeString(PaymentStrings.succeeded);
      case StripePaymentRedirectStatus.requiresAction:
        return context.localeString(PaymentStrings.statusRequiresAction);
      case StripePaymentRedirectStatus.requiresPaymentMethod:
        return context.localeString(PaymentStrings.statusRequiresPaymentMethod);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAllData = widget.params.paymentIntent.isNotEmpty && widget.params.paymentIntentClientSecret.isNotEmpty;

    if (!hasAllData) {
      return NotFoundScreen();
    }
    if (widget.params.redirectStatus != StripePaymentRedirectStatus.succeeded) {
      return PaymentFailed();
    }

    return PaymentSuccessful(params: widget.params);
  }
}

class PaymentSuccessful extends StatelessWidget {
  const PaymentSuccessful({
    super.key,
    required this.params,
  });

  final StripePaymentQueryParams params;

  @override
  Widget build(BuildContext context) {
    return TbScaffold(
      body: Center(
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            PrettyText(context.localeString(PaymentStrings.successfulTitle)),
            PrettyText(
              context.localeString(PaymentStrings.successfulMessage),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TbTextButton(
              onPressed: () => Navigator.of(context).pushNamed('${CalendarScreen.route}?clubId=${params.clubId}&courtId=${params.courtId}'),
              text: context.localeString(PaymentStrings.goToCalendar),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentFailed extends StatelessWidget {
  const PaymentFailed({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TbScaffold(
      body: Center(
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 100),
            const SizedBox(height: 20),
            PrettyText(context.localeString(PaymentStrings.failedTitle)),
            PrettyText(
              context.localeString(PaymentStrings.failedSupport),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TbTextButton(
              onPressed: () => Navigator.of(context).pop(),
              text: context.localeString(GeneralStrings.goBack),
              color: AppColors.red,
            ),
          ],
        ),
      ),
    );
  }
}
