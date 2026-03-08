import 'package:flutter/material.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart' hide Card;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../../global_widgets/index.dart';
import '../../models/index.dart';
import '../../state/index.dart';
import 'payment_result_screen.dart';

String getUrlPort() => web.window.location.port;

String getReturnUrl(String clubId, String courtId) => '${web.window.origin}#${PaymentResultScreen.route}?clubId=$clubId&courtId=$courtId';

Future<void> pay({required String clubId, required String courtId}) async {
  try {
    final paymentIntent = await WebStripe.instance.confirmPaymentElement(
      ConfirmPaymentElementOptions(
        confirmParams: ConfirmPaymentParams(return_url: getReturnUrl(clubId, courtId)),
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

class CasualPaymentForm extends StatefulHookConsumerWidget {
  const CasualPaymentForm({super.key, required this.clientSecret, required this.club, required this.booking, required this.court});

  final String clientSecret;
  final Club club;
  final Court court;
  final Booking booking;

  @override
  ConsumerState<CasualPaymentForm> createState() => _StripePaymentFormModalState();
}

class _StripePaymentFormModalState extends ConsumerState<CasualPaymentForm> {
  bool formIsReady = false;

  Future<void> onPay() async {
    final eventNotifier = ref.read(eventProvider.notifier);
    bool success = true;
    if (formIsReady) {
      eventNotifier.showLoading(title: 'Processing payment');
      await pay(clubId: widget.club.id, courtId: widget.court.id).catchError((_) {
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
    return SizedBox(
      width: mobileView ? 300 : 700,
      child: Column(
        spacing: 50,
        children: [
          _Title(booking: widget.booking),
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
            text: 'Pay \$${widget.club.casualFee} ${widget.club.currency.value.toUpperCase()}',
            onPressed: formIsReady ? onPay : null,
          )
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.booking,
  });

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(booking.startTime);
    final month = DateFormat.MMM().format(date);
    final startTimeString = getLocalTimeFromEpoch(booking.startTime);
    final endTimeString = getLocalTimeFromEpoch(booking.endTime);
    final mobileView = isMobile(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PrettyText(
              '${booking.title}'
              '\n${booking.clubName}'
              '\n${booking.courtName}'
              '\n${date.day}/$month/${date.year}'
              '\nFrom: $startTimeString to $endTimeString',
              textAlign: TextAlign.center,
              maxLines: 7,
              fontSize: getFontSize(mobileView) + 4,
            ),
            SizedBox(height: 10),
            PrettyText(
              'Booking details are: ${booking.private ? 'Private' : 'Public'}',
              textAlign: TextAlign.center,
              fontSize: getFontSize(mobileView),
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
