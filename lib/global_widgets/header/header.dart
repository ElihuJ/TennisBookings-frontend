import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../assets/index.dart';
import '../../config/config.dart';
import '../../screens/home_screen.dart';
import '../../state/index.dart';
import '../../theme/index.dart';
import '../index.dart';
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

    return AppBar(
      leadingWidth: 250,
      toolbarHeight: 80,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Spacer(),
          IconButton(
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onPressed: () => Navigator.of(context).pushNamed(HomeScreen.route),
            icon: Image.asset(logoPgn),
          ),
          Spacer(),
          PrettyText(
            Config.versionString,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      backgroundColor: AppColors.primaryGreen,
      actions: <Widget>[
        Spacer(),
        if (isLoggedIn) InvitesButtonHeader(),
        if (isLoggedIn) const SizedBox(width: 20),
        BookACourtButtonHeader(),
        SizedBox(width: 100),
        Container(
          padding: const EdgeInsets.only(right: 30),
          child: isLoggedIn ? ProfileButton() : LoginRegisterButton(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}
