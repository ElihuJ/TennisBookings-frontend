import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart' hide Card;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../../models/index.dart';
import '../../state/index.dart';
import '../../strings/index.dart';
import '../../theme/colors.dart';
import 'payment_result_screen.dart';
import 'payment_widgets.dart';

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
  ConsumerState<CasualPaymentForm> createState() => _CasualPaymentFormState();
}

class _CasualPaymentFormState extends ConsumerState<CasualPaymentForm> {
  bool formIsReady = false;

  Future<void> onPay() async {
    final eventNotifier = ref.read(eventProvider.notifier);
    bool success = true;
    if (formIsReady) {
      eventNotifier.showLoading(title: context.localeString(PaymentStrings.processing));
      await pay(clubId: widget.club.id, courtId: widget.court.id).catchError((_) {
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
    final date = DateTime.fromMillisecondsSinceEpoch(widget.booking.startTime);
    final dateStr = '${date.day} ${DateFormat.MMM().format(date)} ${date.year}';
    final timeStr = '${getLocalTimeFromEpoch(widget.booking.startTime)} – ${getLocalTimeFromEpoch(widget.booking.endTime)}';
    final visibilityStr = widget.booking.private
        ? context.localeString(PaymentStrings.bookingPrivate)
        : context.localeString(PaymentStrings.bookingPublic);
    final amountStr = '${widget.club.casualFee} ${widget.club.currency.value.toUpperCase()}';

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: mobileView ? 380 : 520),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PaymentCardHeader(
              logoUrl: widget.club.clubLogoUrl,
              title: widget.booking.title,
              subtitle: context.localeString(PaymentStrings.casualTitle),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PaymentInfoRow(icon: Icons.sports_tennis_outlined, value: '${widget.court.name} · ${widget.club.name}'),
                  const SizedBox(height: 8),
                  PaymentInfoRow(icon: Icons.calendar_today_outlined, value: dateStr),
                  const SizedBox(height: 8),
                  PaymentInfoRow(icon: Icons.schedule_outlined, value: timeStr),
                  const SizedBox(height: 8),
                  PaymentInfoRow(
                    icon: widget.booking.private ? Icons.lock_outline : Icons.public_outlined,
                    value: visibilityStr,
                    isLast: true,
                  ),
                  const SizedBox(height: 20),
                  StripeElementContainer(
                    child: PaymentElement(
                      autofocus: true,
                      appearance: ElementAppearance(labels: ElementAppearanceLabels.floating),
                      clientSecret: widget.clientSecret,
                      onCardChanged: (input) => setState(() => formIsReady = input?.complete ?? false),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: formIsReady ? onPay : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      disabledBackgroundColor: AppColors.disabledGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    child: Text('Pay \$$amountStr'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
