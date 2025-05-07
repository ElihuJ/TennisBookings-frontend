import 'package:flutter/material.dart';

import '../../global_helpers/index.dart';
import '../../screens/my_invites/my_invites_screen.dart';
import '../index.dart';

class InvitesButtonHeader extends StatelessWidget {
  const InvitesButtonHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final fontSize = getFontSize(mobile);
    return Container(
      padding: const EdgeInsets.only(left: 0),
      child: TbTextPlainButton(
        text: 'MY INVITES',
        fontSize: fontSize,
        onPressed: () => Navigator.of(context).pushNamed(MyInvitesScreen.route),
      ),
    );
  }
}
