import 'package:flutter/material.dart';

import '../../screens/find_clubs/find_clubs_screen.dart';
import '../index.dart';

class PlayHeaderButton extends StatelessWidget {
  const PlayHeaderButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 0),
      child: TbTextPlainButton(
        text: 'FIND CLUBS', // TODO : TRANSLATE
        onPressed: () => Navigator.of(context).pushNamed(FindClubsScreen.route),
      ),
    );
  }
}
