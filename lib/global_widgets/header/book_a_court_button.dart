import 'package:flutter/material.dart';

import '../../global_helpers/index.dart';
import '../../screens/find_clubs/find_clubs_screen.dart';
import '../index.dart';

class BookACourtButtonHeader extends StatelessWidget {
  const BookACourtButtonHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final fontSize = getFontSize(mobile);
    return Container(
      padding: const EdgeInsets.only(left: 0),
      child: TbClickableText(
        text: 'BOOKINGS',
        fontSize: fontSize,
        onPressed: () => Navigator.of(context).pushNamed(FindClubsScreen.route),
      ),
    );
  }
}
