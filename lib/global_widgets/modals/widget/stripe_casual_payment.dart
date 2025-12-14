import 'package:flutter/material.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart' hide Card;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web/web.dart' as web;

import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';
import '../../../screens/club_membership/payment_result_screen.dart';
import '../../../state/index.dart';
import '../../index.dart';

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

class StripePaymentModalForm extends StatefulHookConsumerWidget {
  const StripePaymentModalForm({super.key, required this.clientSecret, required this.club, required this.booking, required this.court});

  final String clientSecret;
  final Club club;
  final Court court;
  final Booking booking;

  @override
  ConsumerState<StripePaymentModalForm> createState() => _StripePaymentFormModalState();
}

class _StripePaymentFormModalState extends ConsumerState<StripePaymentModalForm> {
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
    return SingleChildScrollView(
      child: Column(
        spacing: 50,
        children: [
          _Title(club: widget.club, booking: widget.booking),
          Padding(
            padding: const EdgeInsets.all(20),
            child: PaymentElement(
              autofocus: true,
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
    required this.club,
    required this.booking,
  });

  final Club club;
  final Booking booking;

  @override
  Widget build(BuildContext context) {
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
              '${club.name}'
              '\nFrom: $startTimeString to $endTimeString',
              textAlign: TextAlign.center,
              maxLines: 5,
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
