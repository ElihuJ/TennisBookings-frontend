import 'package:flutter/material.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_helpers/index.dart';
import 'package:tennisbookings/global_types/index.dart';
import 'package:tennisbookings/global_widgets/index.dart';
import 'package:tennisbookings/screens/club_membership/payment_result_screen.dart';
import 'package:tennisbookings/state/index.dart';
import 'package:web/web.dart' as web;

String getUrlPort() => web.window.location.port;

String getReturnUrl() => '${web.window.origin}#${PaymentResultScreen.route}';

Future<void> pay() async {
  try {
    final paymentIntent = await WebStripe.instance.confirmPaymentElement(
      ConfirmPaymentElementOptions(
        confirmParams: ConfirmPaymentParams(return_url: getReturnUrl()),
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

class StripePaymentForm extends StatefulHookConsumerWidget {
  const StripePaymentForm({super.key, required this.clientSecret, required this.club});

  final String clientSecret;
  final Club club;

  @override
  ConsumerState<StripePaymentForm> createState() => _StripePaymentFormState();
}

class _StripePaymentFormState extends ConsumerState<StripePaymentForm> {
  bool formIsReady = false;

  Future<void> onPay() async {
    final eventNotifier = ref.read(eventProvider.notifier);
    bool success = true;
    if (formIsReady) {
      eventNotifier.showLoading(title: 'Processing payment');
      await pay().catchError((_) {
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
    final fontSize = getFontSize(mobileView);

    return SizedBox(
      width: mobileView ? 300 : 700,
      child: Column(
        spacing: 50,
        children: [
          _Title(club: widget.club, fontSize: fontSize),
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
            text: 'Pay \$${widget.club.annualFee}',
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
    required this.fontSize,
  });

  final Club club;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
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
          fontSize: fontSize + 4,
        ),
        SizedBox(height: 10),
        PrettyText(
          'Valid until $aYearFromNowString',
          textAlign: TextAlign.center,
          fontSize: fontSize,
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
