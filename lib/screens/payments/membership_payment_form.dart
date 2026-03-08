import 'package:flutter/material.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web/web.dart' as web;

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../../global_widgets/index.dart';
import '../../state/index.dart';
import 'payment_result_screen.dart';

String getUrlPort() => web.window.location.port;

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
    e.tbLogger('Stripe error confirming payment', DebugLevel.error);
    rethrow;
  } catch (e) {
    e.tbLogger('Error confirming payment', DebugLevel.error);
    rethrow;
  }
}

class MembershipPaymentForm extends StatefulHookConsumerWidget {
  const MembershipPaymentForm({super.key, required this.clientSecret, required this.club});

  final String clientSecret;
  final Club club;

  @override
  ConsumerState<MembershipPaymentForm> createState() => _StripePaymentFormState();
}

class _StripePaymentFormState extends ConsumerState<MembershipPaymentForm> {
  bool formIsReady = false;

  Future<void> onPay() async {
    final eventNotifier = ref.read(eventProvider.notifier);
    bool success = true;
    if (formIsReady) {
      eventNotifier.showLoading(title: 'Processing payment');
      await pay(clubId: widget.club.id).catchError((_) {
        eventNotifier.hideLoading();
        eventNotifier.showMessage(message: 'Payment failed', messageType: MessageType.error);
        success = false;
        return;
      }).then((_) {
        if (success) {
          eventNotifier.hideLoading();
          eventNotifier.showMessage(message: 'Payment succeeded', messageType: MessageType.success);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);

    widget.club.currency.tbLogger('Currency', DebugLevel.warning);

    return SizedBox(
      width: mobileView ? 300 : 700,
      child: Column(
        spacing: 50,
        children: [
          _Title(club: widget.club),
          Padding(
            padding: const EdgeInsets.all(20),
            child: PaymentElement(
              autofocus: true,
              appearance: ElementAppearance(labels: ElementAppearanceLabels.floating),
              clientSecret: widget.clientSecret,
              onCardChanged: (input) {
                setState(() {
                  formIsReady = input?.complete ?? false;
                });
              },
            ),
          ),
          TbTextButton(
            text: 'Pay \$${widget.club.annualFee} ${widget.club.currency.value.toUpperCase()}',
            onPressed: formIsReady ? onPay : null,
          )
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.club,
  });

  final Club club;

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);
    final now = DateTime.now();
    final aYearFromNow = DateTime(now.year + 1, now.month, now.day);
    final aYearFromNowString = prettyDateLocalFromEpoch(aYearFromNow.millisecondsSinceEpoch);
    return Column(
      children: [
        PrettyText(
          '${club.name}'
          '\nAnnual membership fee',
          textAlign: TextAlign.center,
          maxLines: 2,
          fontSize: getFontSize(mobileView) + 4,
        ),
        SizedBox(height: 10),
        PrettyText(
          'Valid until $aYearFromNowString',
          textAlign: TextAlign.center,
          fontSize: getFontSize(mobileView),
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
