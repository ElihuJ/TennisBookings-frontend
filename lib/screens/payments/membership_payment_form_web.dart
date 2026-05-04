import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart' hide Card;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web/web.dart' as web;

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../../state/index.dart';
import '../../strings/index.dart';
import 'payment_result_screen.dart';
import 'payment_widgets.dart';

String getReturnUrl(String clubId) => '${web.window.origin}#${PaymentResultScreen.route}?clubId=$clubId';

Future<void> pay({required String clubId}) async {
  try {
    final paymentIntent = await WebStripe.instance.confirmPaymentElement(
      ConfirmPaymentElementOptions(
        confirmParams: ConfirmPaymentParams(return_url: getReturnUrl(clubId)),
      ),
    );
    paymentIntent.tbLogger('PaymentIntent', DebugLevel.warning);
    'Confirmation Method'.tbLogger(paymentIntent.confirmationMethod.toString());
  } on StripeError catch (e) {
    e.tbLogger('Stripe error confirming membership payment', DebugLevel.error);
    rethrow;
  } catch (e) {
    e.tbLogger('Error confirming membership payment', DebugLevel.error);
    rethrow;
  }
}

class MembershipPaymentForm extends StatefulHookConsumerWidget {
  const MembershipPaymentForm({super.key, required this.clientSecret, required this.club});

  final String clientSecret;
  final Club club;

  @override
  ConsumerState<MembershipPaymentForm> createState() => _MembershipPaymentFormState();
}

class _MembershipPaymentFormState extends ConsumerState<MembershipPaymentForm> {
  bool formIsReady = false;

  Future<void> onPay() async {
    final eventNotifier = ref.read(eventProvider.notifier);
    bool success = true;
    if (formIsReady) {
      eventNotifier.showLoading(title: context.localeString(PaymentStrings.processing));
      await pay(clubId: widget.club.id).catchError((_) {
        eventNotifier.hideLoading();
        eventNotifier.showMessage(message: context.localeString(PaymentStrings.failed), messageType: MessageType.error);
        success = false;
        return;
      }).then((_) {
        if (success) {
          eventNotifier.hideLoading();
          eventNotifier.showMessage(message: context.localeString(PaymentStrings.succeeded), messageType: MessageType.success);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);
    final now = DateTime.now();
    final validUntil = prettyDateLocalFromEpoch(DateTime(now.year + 1, now.month, now.day).millisecondsSinceEpoch);
    final amountStr = '${widget.club.annualFee} ${widget.club.currency.value.toUpperCase()}';

    return PaymentFormCard(
      isMobile: mobileView,
      header: PaymentCardHeader(
        logoUrl: widget.club.clubLogoUrl,
        title: widget.club.name,
        subtitle: context.localeString(PaymentStrings.membershipTitle),
      ),
      infoRows: [
        PaymentInfoRow(icon: Icons.card_membership_outlined, value: context.localeString(PaymentStrings.annualFee)),
        const SizedBox(height: 8),
        PaymentInfoRow(
          icon: Icons.event_available_outlined,
          value: '${context.localeString(PaymentStrings.validUntil)} $validUntil',
          isLast: true,
        ),
      ],
      paymentInput: StripeElementContainer(
        child: PaymentElement(
          autofocus: true,
          appearance: ElementAppearance(labels: ElementAppearanceLabels.floating),
          clientSecret: widget.clientSecret,
          onCardChanged: (input) => setState(() => formIsReady = input?.complete ?? false),
        ),
      ),
      payButtonLabel: 'Pay \$$amountStr',
      formIsReady: formIsReady,
      onPay: onPay,
    );
  }
}
