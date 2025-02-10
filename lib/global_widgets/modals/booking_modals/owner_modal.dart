import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../models/index.dart';
import '../../../screens/club/widgets/index.dart';
import '../../../screens/login/email_login_screen.dart';
import '../../../screens/login/login_screen.dart';
import '../../../screens/login/types.dart';
import '../../index.dart';

class OwnerBookingModal extends HookConsumerWidget {
  const OwnerBookingModal({super.key, required this.booking, required this.clubId});

  final Booking booking;
  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: PrettyText(booking.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          PlayerIcons(confirmedPlayerIds: booking.confirmedPlayerIds, booking: booking, clubId: clubId, type: PlayerIconsType.column),
        ],
      ),
      actions: getActions(context),
    );
  }
}

getActions(BuildContext context) {
  return [
    TextButton(
      child: Text('Login'),
      onPressed: () => Navigator.of(context).pushNamed(LoginScreen.route),
    ),
    TextButton(
      child: Text('Register'),
      onPressed: () => Navigator.of(context).pushNamed(EmailLoginScreen.route, arguments: ScreenMode.register),
    ),
  ];
}

void showOwnerBookingDetailsModal({required BuildContext context, required Booking booking, required String clubId}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return OwnerBookingModal(booking: booking, clubId: clubId);
    },
  );
}
