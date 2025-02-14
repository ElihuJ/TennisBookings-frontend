import 'package:flutter/material.dart';

import '../../../models/index.dart';
import '../../../screens/club/widgets/index.dart';

class ParticipantModal extends StatelessWidget {
  const ParticipantModal({super.key, required this.booking, required this.type});

  final Booking booking;
  final PlayerIconsType type;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(booking.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('You are a participant of this booking. What would you like to do?'),
          PlayerIcons(confirmedPlayerIds: booking.confirmedPlayerIds, booking: booking, type: type)
        ],
      ),
      actions: <Widget>[
        // TextButton(
        //   child: Text('Login'),
        //   onPressed: () => Navigator.of(context).pushNamed(LoginScreen.route),
        // ),
        // TextButton(
        //   child: Text('Register'),
        //   onPressed: () => Navigator.of(context).pushNamed(EmailLoginScreen.route, arguments: ScreenMode.register),
        // ),
      ],
    );
  }
}

void showParticipantBookingDetailsModal({required BuildContext context, required Booking booking, required PlayerIconsType type}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ParticipantModal(booking: booking, type: type);
    },
  );
}
