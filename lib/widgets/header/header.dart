import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/assets/icons.dart';
import 'package:tennisbookings/helpers/logs.dart';
import 'package:tennisbookings/theme/index.dart';

import 'index.dart';

class Header extends HookConsumerWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
    final isLoggedIn = currentUser != null && currentUser.emailVerified;
    ''.tbLogger('Header, $logoPgn');

    return AppBar(
      leadingWidth: 180,
      toolbarHeight: 80,
      leading: IconButton(
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onPressed: () {},
        icon: Image.asset(logoPgn),
      ),
      backgroundColor: AppColors.primaryGreen,
      actions: <Widget>[
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
