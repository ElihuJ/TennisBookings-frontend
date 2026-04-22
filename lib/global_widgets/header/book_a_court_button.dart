import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../screens/find_clubs/find_clubs_screen.dart';
import '../../strings/index.dart';

class BookACourtButtonHeader extends StatelessWidget {
  const BookACourtButtonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return _NavButton(
      label: context.localeString(GeneralStrings.headerBookings),
      onPressed: () => Navigator.of(context).pushNamed(FindClubsScreen.route),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        overlayColor: Colors.white.withValues(alpha: 0.12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
