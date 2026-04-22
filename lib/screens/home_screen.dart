import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../global_helpers/index.dart';
import '../global_widgets/index.dart';
import '../strings/index.dart';
import '../theme/index.dart';
import 'find_clubs/find_clubs_screen.dart';
import 'login/widgets/containers.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  static const route = 'Home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mobileView = isMobile(context);

    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: TbScaffold(
          body: ContainerWithBackground(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: mobileView ? 16 : 32,
                      vertical: 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        _HeroCard(mobileView: mobileView),
                        const SizedBox(height: 32),
                        _FeaturesSection(mobileView: mobileView),
                        const SizedBox(height: 24),
                        _ContactCard(),
                        const SizedBox(height: 48),
                        _Footer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.mobileView});

  final bool mobileView;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: mobileView ? 36 : 52,
        horizontal: mobileView ? 24 : 48,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          TbLogoWhite(width: mobileView ? 180 : 230),
          const SizedBox(height: 28),
          Text(
            context.localeString(HomeStrings.heroTitle),
            style: TextStyle(
              fontSize: mobileView ? 30 : 48,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            context.localeString(HomeStrings.heroSubtitle),
            style: TextStyle(
              fontSize: mobileView ? 14 : 17,
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(FindClubsScreen.route),
            icon: const Icon(Icons.search, size: 18),
            label: Text(
              context.localeString(HomeStrings.footerGetStarted),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.darkGreen,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Features ─────────────────────────────────────────────────────────────────

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({required this.mobileView});

  final bool mobileView;

  @override
  Widget build(BuildContext context) {
    final features = [
      (
        Icons.search_rounded,
        context.localeString(HomeStrings.featureSearchTitle),
        context.localeString(HomeStrings.featureSearchSubtitle),
      ),
      (
        Icons.group_outlined,
        context.localeString(HomeStrings.featureInviteTitle),
        context.localeString(HomeStrings.featureInviteSubtitle),
      ),
      (
        Icons.payments_outlined,
        context.localeString(HomeStrings.featurePaymentsTitle),
        context.localeString(HomeStrings.featurePaymentsSubtitle),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.localeString(HomeStrings.featuresSection),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGreen,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        mobileView
            ? Column(
                children: features
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _FeatureCard(icon: f.$1, title: f.$2, subtitle: f.$3),
                        ))
                    .toList(),
              )
            : Row(
                children: features
                    .map((f) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _FeatureCard(icon: f.$1, title: f.$2, subtitle: f.$3),
                          ),
                        ))
                    .toList(),
              ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.darkGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.grey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Contact ──────────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.contacts_outlined, size: 18, color: AppColors.primaryGreen),
                  const SizedBox(width: 10),
                  Text(
                    context.localeString(HomeStrings.contactSection),
                    style: const TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _ContactRow(icon: Icons.email_outlined, value: 'info@tennisbookings.com.au'),
            const Divider(height: 1, indent: 52, endIndent: 16),
            _ContactRow(icon: Icons.phone_outlined, value: '+61 0494 130 692'),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 14),
          SelectableText(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.localeString(HomeStrings.footerReady),
          style: const TextStyle(fontSize: 18, color: AppColors.darkGreen, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).pushNamed(FindClubsScreen.route),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            context.localeString(HomeStrings.footerGetStarted),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '© ${DateTime.now().year} TennisBookings',
          style: TextStyle(color: AppColors.grey, fontSize: 13),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
