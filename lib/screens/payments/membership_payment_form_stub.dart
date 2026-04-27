import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../../state/index.dart';
import '../../strings/index.dart';
import '../../theme/colors.dart';
import 'payment_widgets.dart';

class MembershipPaymentForm extends StatefulHookConsumerWidget {
  const MembershipPaymentForm({super.key, required this.clientSecret, required this.club});

  final String clientSecret;
  final Club club;

  @override
  ConsumerState<MembershipPaymentForm> createState() => _MembershipPaymentFormState();
}

class _MembershipPaymentFormState extends ConsumerState<MembershipPaymentForm> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initPaymentSheet();
  }

  Future<void> _initPaymentSheet() async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: widget.clientSecret,
          merchantDisplayName: widget.club.name,
          style: ThemeMode.system,
        ),
      );
      if (mounted) setState(() => _isReady = true);
    } catch (e) {
      e.tbLogger('Error initializing payment sheet', DebugLevel.error);
    }
  }

  Future<void> onPay() async {
    final eventNotifier = ref.read(eventProvider.notifier);
    try {
      await Stripe.instance.presentPaymentSheet();
      if (!mounted) return;
      eventNotifier.showMessage(
        message: context.localeString(PaymentStrings.succeeded),
        messageType: MessageType.success,
      );
      Navigator.of(context).pop();
    } on StripeException catch (e) {
      if (e.error.code != FailureCode.Canceled) {
        eventNotifier.showMessage(
          message: context.localeString(PaymentStrings.failed),
          messageType: MessageType.error,
        );
      }
    } catch (e) {
      eventNotifier.showMessage(
        message: context.localeString(PaymentStrings.failed),
        messageType: MessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);
    final now = DateTime.now();
    final validUntil = prettyDateLocalFromEpoch(DateTime(now.year + 1, now.month, now.day).millisecondsSinceEpoch);
    final amountStr = '${widget.club.annualFee} ${widget.club.currency.value.toUpperCase()}';

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
              title: widget.club.name,
              subtitle: context.localeString(PaymentStrings.membershipTitle),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PaymentInfoRow(icon: Icons.card_membership_outlined, value: context.localeString(PaymentStrings.annualFee)),
                  const SizedBox(height: 8),
                  PaymentInfoRow(
                    icon: Icons.event_available_outlined,
                    value: '${context.localeString(PaymentStrings.validUntil)} $validUntil',
                    isLast: true,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _isReady ? onPay : null,
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
