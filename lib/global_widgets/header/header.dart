import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../assets/index.dart';
import '../../global_helpers/index.dart';
import '../../screens/home_screen.dart';
import '../../state/clubs/index.dart';
import '../../state/index.dart';
import '../../theme/index.dart';
import 'index.dart';
import 'play_button.dart';

class Header extends HookConsumerWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(firebaseAuthProvider);
    final clubs = ref.watch(clubsProvider);
    final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
    final user = ref.watch(userProvider);
    final isLoggedIn = currentUser != null && currentUser.emailVerified;

    clubs.tbLogger('CLUBS');
    user.tbLogger('USER');

    return AppBar(
      leadingWidth: 180,
      toolbarHeight: 80,
      leading: IconButton(
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onPressed: () => Navigator.of(context).pushNamed(HomeScreen.route),
        icon: Image.asset(logoPgn),
      ),
      backgroundColor: AppColors.primaryGreen,
      actions: <Widget>[
        Spacer(),
        PlayHeaderButton(),
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
