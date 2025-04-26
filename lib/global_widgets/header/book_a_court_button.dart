import 'package:flutter/material.dart';

import '../../screens/find_clubs/find_clubs_screen.dart';
import '../index.dart';

class BookACourtButtonHeader extends StatelessWidget {
  const BookACourtButtonHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 0),
      child: TbTextPlainButton(
        text: 'BOOKINGS',
        onPressed: () => Navigator.of(context).pushNamed(FindClubsScreen.route),
      ),
    );
  }
}
