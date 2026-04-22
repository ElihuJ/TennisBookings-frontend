import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../config/config.dart';
import '../../global_helpers/index.dart';
import '../../global_widgets/logo/tb_logo.dart';
import '../../strings/index.dart';
import '../../global_types/index.dart';
import '../../screens/home_screen.dart';
import '../../state/index.dart';
import '../../theme/index.dart';
import 'book_a_court_button.dart';
import 'index.dart';
import 'invites_button.dart';

class Header extends HookConsumerWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(firebaseAuthProvider);
    final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
    final isLoggedIn = currentUser != null && currentUser.emailVerified;
    final mobileView = isMobile(context);
    final env = Config().environment;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryGreen, AppColors.darkGreen],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
      ),
      leadingWidth: mobileView ? 150 : 250,
      toolbarHeight: 72,
      leading: mobileView ? const MobileLeading() : const DesktopLeading(),
      actions: [
        if (!mobileView) const Spacer(),
        if (env != Environment.prod)
          _VersionChip(context: context),
        if (isLoggedIn) const InvitesButtonHeader(),
        if (isLoggedIn && !mobileView) const SizedBox(width: 8),
        const BookACourtButtonHeader(),
        SizedBox(width: mobileView ? 12 : 24),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: isLoggedIn ? const ProfileButton() : const LoginRegisterButton(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class _VersionChip extends StatelessWidget {
  const _VersionChip({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final env = Config().environment;
    return Center(
      child: GestureDetector(
        onTap: () => showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              ctx.localeString(GeneralStrings.headerVersionTitle),
              textAlign: TextAlign.center,
            ),
            content: Text('${env.toString()} - ${Config.versionString}\n${Config.latestNotes}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(ctx.localeString(GeneralStrings.headerVersionButton)),
              ),
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Text(
            Config().envString,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class MobileLeading extends StatelessWidget {
  const MobileLeading({super.key});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(HomeScreen.route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TbLogoWhite(width: 120),
        ),
      ),
    );
  }
}

class DesktopLeading extends StatelessWidget {
  const DesktopLeading({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(HomeScreen.route),
            child: TbLogoWhite(width: 140),
          ),
        ),
        const Spacer(),
        Text(
          Config.versionString,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
        ),
      ],
    );
  }
}
