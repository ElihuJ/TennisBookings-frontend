import 'package:flutter/material.dart';
import 'package:tennisbookings/screens/my_invites/my_invites_screen.dart';

import '../index.dart';

class InvitesButtonHeader extends StatelessWidget {
  const InvitesButtonHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 0),
      child: TbTextPlainButton(
        text: 'MY INVITES',
        onPressed: () => Navigator.of(context).pushNamed(MyInvitesScreen.route),
      ),
    );
  }
}
