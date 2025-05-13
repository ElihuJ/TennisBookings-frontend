import 'package:flutter/material.dart';
import 'package:tennisbookings/global_helpers/index.dart';

import '../../assets/index.dart';
import '../../config/config.dart';
import '../../screens/home_screen.dart';
import '../../theme/index.dart';
import '../text/index.dart';

class TbDrawer extends StatelessWidget {
  const TbDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);

    if (!mobileView) {
      ''.tbLogger('Drawer is not visible on desktop');
      return const SizedBox.shrink();
    }

    ''.tbLogger('Drawer is visible on mobile');

    return Drawer(
      backgroundColor: AppColors.white,
      width: 100,
      child: Container(
        height: 100,
        width: 100,
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            IconButton(
              highlightColor: Colors.white,
              hoverColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed(HomeScreen.route);
              },
              icon: Image.asset(logoPgn, width: 130),
            ),
            const SizedBox(height: 20),
            PrettyText(
              Config.versionString,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
