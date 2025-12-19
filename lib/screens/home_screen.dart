import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/screens/find_clubs/find_clubs_screen.dart';

import '../assets/index.dart';
import '../global_widgets/index.dart';
import '../theme/index.dart';
import 'login/widgets/containers.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  static const route = 'Home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final smallScreen = screenWidth < 800;

    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: TbScaffold(
          body: ContainerWithBackground(
            imagePath: homeBackgroundPng,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 24),

                  // Hero section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: smallScreen ? 20 : 80),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black.withValues(alpha: 0.28),
                        border: Border.all(color: AppColors.almostWhite.withValues(alpha: 0.12)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.32), blurRadius: 24, offset: Offset(0, 12)),
                        ],
                        backgroundBlendMode: BlendMode.multiply,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(smallScreen ? 24 : 48),
                        child: Column(
                          children: [
                            PrettyText(
                              'Book. Play. Connect.',
                              style: TextStyle(
                                fontSize: smallScreen ? 28 : 56,
                                fontWeight: FontWeight.w800,
                                color: AppColors.almostWhite,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12),
                            PrettyText(
                              'Find courts nearby, invite players and manage bookings — all in one beautiful app.',
                              style: TextStyle(fontSize: smallScreen ? 14 : 18, color: AppColors.almostWhite.withValues(alpha: 0.95)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 36),

                  // Features
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: smallScreen ? 16 : 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PrettyText('Features', style: TextStyle(fontSize: 20, color: AppColors.almostWhite, fontWeight: FontWeight.w700)),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _featureTile(Icons.search, 'Quick search', 'Find courts and partners fast', smallScreen),
                            _featureTile(Icons.group, 'Invite players', 'Share invites and confirm partners', smallScreen),
                            _featureTile(Icons.payments, 'Payments', 'Secure casual & membership payments', smallScreen),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),
                  // * About + Contact placeholders
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: smallScreen ? 16 : 80),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PrettyText('Contact', style: TextStyle(fontSize: 18, color: AppColors.white)),
                            SizedBox(height: 10),
                            Row(children: [
                              Icon(Icons.email, color: AppColors.almostWhite),
                              SizedBox(width: 10),
                              PrettyText('info@tennisbookings.com.au',
                                  style: TextStyle(color: AppColors.almostWhite.withValues(alpha: 0.85)))
                            ]),
                            SizedBox(height: 8),
                            Row(children: [
                              Icon(Icons.phone, color: AppColors.almostWhite),
                              SizedBox(width: 10),
                              PrettyText('+61 0494 130 692', style: TextStyle(color: AppColors.almostWhite.withValues(alpha: 0.85)))
                            ]),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 48),

                  // *  Footer
                  _Footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          PrettyText('Ready to play?', style: TextStyle(fontSize: 18, color: AppColors.almostWhite)),
          SizedBox(height: 12),
          TbTextButton(text: 'Get Started', width: 200, onPressed: () => Navigator.of(context).pushNamed(FindClubsScreen.route)),
          SizedBox(height: 12),
          PrettyText('© ${DateTime.now().year} TennisBookings', style: TextStyle(color: AppColors.almostWhite.withValues(alpha: 0.6))),
          SizedBox(height: 80),
        ],
      ),
    );
  }
}

Widget _featureTile(IconData icon, String title, String subtitle, bool small) {
  return Expanded(
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white, size: small ? 20 : 28),
            ),
            SizedBox(height: 10),
            PrettyText(title, style: TextStyle(fontSize: small ? 14 : 16, color: AppColors.almostWhite, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            PrettyText(subtitle, style: TextStyle(fontSize: small ? 12 : 14, color: AppColors.almostWhite.withValues(alpha: 0.9))),
          ],
        ),
      ),
    ),
  );
}
