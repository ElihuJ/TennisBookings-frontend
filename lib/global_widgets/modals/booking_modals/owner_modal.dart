import 'package:flutter/material.dart';
import 'package:tennisbookings/global_widgets/containers/bordered_box.dart';
import 'package:tennisbookings/models/index.dart';

import '../../../screens/login/email_login_screen.dart';
import '../../../screens/login/login_screen.dart';
import '../../../screens/login/types.dart';

class OwnerBookingModal extends StatelessWidget {
  const OwnerBookingModal({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(booking.title),
      content: BorderedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text('What would you like to do?'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Login'),
          onPressed: () => Navigator.of(context).pushNamed(LoginScreen.route),
        ),
        TextButton(
          child: Text('Register'),
          onPressed: () => Navigator.of(context).pushNamed(EmailLoginScreen.route, arguments: ScreenMode.register),
        ),
      ],
    );
  }
}

void showOwnerBookingDetailsModal({required BuildContext context, required Booking booking}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return OwnerBookingModal(booking: booking);
    },
  );
}
