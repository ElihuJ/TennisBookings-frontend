import 'package:flutter/material.dart';
import 'package:tennisbookings/global_helpers/index.dart';

import '../../screens/find_clubs/find_clubs_screen.dart';
import '../index.dart';

class BookACourtButtonHeader extends StatelessWidget {
  const BookACourtButtonHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    return Container(
      padding: const EdgeInsets.only(left: 0),
      child: TbTextPlainButton(
        text: 'BOOKINGS',
        fontSize: mobile ? 12 : 16,
        onPressed: () => Navigator.of(context).pushNamed(FindClubsScreen.route),
      ),
    );
  }
}
