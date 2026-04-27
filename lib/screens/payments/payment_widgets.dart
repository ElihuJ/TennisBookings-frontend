import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Green gradient card header shared by both payment forms.
class PaymentCardHeader extends StatelessWidget {
  const PaymentCardHeader({
    super.key,
    required this.logoUrl,
    required this.title,
    required this.subtitle,
  });

  final String logoUrl;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.courtGreen, AppColors.darkGreen],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white.withValues(alpha: 0.2),
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundImage: NetworkImage(logoUrl),
              backgroundColor: AppColors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.78),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon + value info row used in payment summaries.
class PaymentInfoRow extends StatelessWidget {
  const PaymentInfoRow({
    super.key,
    required this.icon,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceGreenAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderGreen),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textBody,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stripe element container with subtle green surface styling.
class StripeElementContainer extends StatelessWidget {
  const StripeElementContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: child,
    );
  }
}

/// Skeleton card shown while payment intent is loading.
/// Renders the real gradient header with a spinner body so the layout
/// doesn't jump when the form appears.
class PaymentCardSkeleton extends StatelessWidget {
  const PaymentCardSkeleton({super.key, required this.header, required this.isMobile});

  final Widget header;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isMobile ? 380 : 520),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 52),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient header for payment result screens (success / failure).
class PaymentResultHeader extends StatelessWidget {
  const PaymentResultHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.isSuccess,
  });

  final IconData icon;
  final String title;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSuccess
              ? [AppColors.courtGreen, AppColors.darkGreen]
              : [AppColors.dangerRed, AppColors.errorRed],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white.withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: AppColors.white, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
