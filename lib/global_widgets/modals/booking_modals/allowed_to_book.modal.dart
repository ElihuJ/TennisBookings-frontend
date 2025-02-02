import 'package:flutter/material.dart';
import 'package:tennisbookings/models/index.dart';

import '../../../screens/login/email_login_screen.dart';
import '../../../screens/login/login_screen.dart';
import '../../../screens/login/types.dart';

class AllowedToBookModal extends StatelessWidget {
  const AllowedToBookModal({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(booking.title),
      content: Text('You are allowed to send invites on this booking. What would you like to do?'),
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

void showAllowedToBookModal({required BuildContext context, required Booking booking}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AllowedToBookModal(booking: booking);
    },
  );
}
