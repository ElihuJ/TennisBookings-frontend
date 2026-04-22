import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../state/index.dart';
import '../../strings/index.dart';
import '../../theme/index.dart';
import '../home_screen.dart';
import 'profile_screen.dart';

class OptionsDrawer extends HookConsumerWidget {
  const OptionsDrawer({
    super.key,
    required this.toggleSelectedOption,
    required this.selectedOption,
  });

  final void Function(ProfileOptions option) toggleSelectedOption;
  final ProfileOptions selectedOption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fbNotifier = ref.read(firebaseAuthProvider.notifier);
    final clubNotifier = ref.read(clubsProvider.notifier);
    final screenWidth = MediaQuery.of(context).size.width;
    final smallScreen = screenWidth < 600;

    return Container(
      width: smallScreen ? 72 : 240,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _DrawerHeader(smallScreen: smallScreen),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _NavItem(
                  icon: Icons.person_outline,
                  label: context.localeString(ProfileStrings.details),
                  selected: selectedOption == ProfileOptions.profileDetails,
                  smallScreen: smallScreen,
                  onTap: () => toggleSelectedOption(ProfileOptions.profileDetails),
                ),
                _NavItem(
                  icon: Icons.card_membership_outlined,
                  label: context.localeString(ProfileStrings.memberships),
                  selected: selectedOption == ProfileOptions.memberships,
                  smallScreen: smallScreen,
                  onTap: () => toggleSelectedOption(ProfileOptions.memberships),
                ),
                _NavItem(
                  icon: Icons.sports_tennis_outlined,
                  label: context.localeString(ProfileStrings.myBookings),
                  selected: selectedOption == ProfileOptions.myBookings,
                  smallScreen: smallScreen,
                  onTap: () => toggleSelectedOption(ProfileOptions.myBookings),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 12, endIndent: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: _NavItem(
              icon: Icons.exit_to_app_outlined,
              label: context.localeString(ProfileStrings.logout),
              selected: false,
              smallScreen: smallScreen,
              isDestructive: true,
              onTap: () async {
                await fbNotifier.logout();
                clubNotifier.clearPrivateBookings();
                if (context.mounted) {
                  Navigator.of(context).pushNamed(HomeScreen.route);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.smallScreen});

  final bool smallScreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: smallScreen ? 20 : 24,
        horizontal: smallScreen ? 0 : 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: smallScreen
          ? const Center(
              child: Icon(Icons.sports_tennis, color: Colors.white, size: 28),
            )
          : const Row(
              children: [
                Icon(Icons.sports_tennis, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Nav item ─────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.smallScreen,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool smallScreen;
  final bool isDestructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = isDestructive ? AppColors.red : AppColors.primaryGreen;
    final Color iconColor = selected
        ? activeColor
        : isDestructive
            ? AppColors.red.withValues(alpha: 0.7)
            : AppColors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: smallScreen ? 0 : 12,
            ),
            decoration: BoxDecoration(
              color: selected ? activeColor.withValues(alpha: 0.10) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: selected ? Border(left: BorderSide(color: activeColor, width: 3)) : null,
            ),
            child: smallScreen
                ? Center(child: Icon(icon, size: 22, color: iconColor))
                : Row(
                    children: [
                      const SizedBox(width: 4),
                      Icon(icon, size: 20, color: iconColor),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? activeColor : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
