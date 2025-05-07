import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/screens/profile/profile_screen.dart';
import 'package:web/web.dart' as web;

import '../../global_widgets/header/header.dart';
import '../../global_widgets/index.dart';
import '../../routes/index.dart';
import '../../theme/index.dart';

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
        return 'Payment succeeded';
      case StripePaymentRedirectStatus.requiresAction:
        return 'Payment incomplete, requires action';
      case StripePaymentRedirectStatus.requiresPaymentMethod:
        return 'Payment failed, requires payment method';
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

    return PaymentSuccessful();
  }
}

class PaymentSuccessful extends StatelessWidget {
  const PaymentSuccessful({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      body: Center(
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            PrettyText(
              'Payment Successful!',
            ),
            PrettyText(
              'Thank you for your payment. Your transaction was successful.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TbTextButton(
              onPressed: () => Navigator.of(context).pushNamed(ProfileScreen.route),
              text: 'Go to Dashboard',
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
    return Scaffold(
      appBar: Header(),
      body: Center(
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 100),
            const SizedBox(height: 20),
            PrettyText(
              'Payment Failed',
            ),
            PrettyText(
              'Please try again or contact support.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TbTextButton(
              onPressed: () => Navigator.of(context).pop(),
              text: 'Go Back',
              color: AppColors.red,
            ),
          ],
        ),
      ),
    );
  }
}
