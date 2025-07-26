import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../assets/index.dart';
import '../../config/config.dart';
import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
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
    final mobileView = isMobile(context);
    final env = Config().environment;

    return AppBar(
      leadingWidth: mobileView ? 150 : 250,
      toolbarHeight: 80,
      leading: mobileView ? MobileLeading() : DesktopLeading(),
      backgroundColor: AppColors.primaryGreen,
      actions: <Widget>[
        if (!mobileView) Spacer(),
        if (env != Environment.prod)
          TbClickableText(
            text: Config().envString,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const PrettyText('Version', textAlign: TextAlign.center),
                  content: PrettyText('${env.toString()} - ${Config.versionString}'
                      '\n${Config.latestNotes}'),
                  actions: <Widget>[
                    TbTextButton(
                      text: 'Cool!',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
        if (isLoggedIn) InvitesButtonHeader(),
        if (isLoggedIn && !mobileView) const SizedBox(width: 20),
        BookACourtButtonHeader(),
        SizedBox(width: mobileView ? 20 : 100),
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

class MobileLeading extends StatelessWidget {
  const MobileLeading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      highlightColor: AppColors.secondaryGreen,
      onPressed: () {
        Navigator.of(context).pushNamed(HomeScreen.route);
      },
      icon: Image.asset(
        logoPgn,
        width: 130,
      ),
    );
  }
}

class DesktopLeading extends StatelessWidget {
  const DesktopLeading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Spacer(),
        IconButton(
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onPressed: () {
            Navigator.of(context).pushNamed(HomeScreen.route);
          },
          icon: Image.asset(logoPgn, width: 130),
        ),
        Spacer(),
        PrettyText(
          Config.versionString,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
