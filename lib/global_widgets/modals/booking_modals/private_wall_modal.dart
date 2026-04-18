import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../strings/index.dart';
import '../../text/index.dart';

void showPrivateWallModal({required BuildContext context, String? message}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: PrettyText(context.localeString(BookingModalStrings.privateBooking)),
        content: PrettyText(message ?? context.localeString(BookingModalStrings.privateBookingMessage)),
        actions: <Widget>[
          TextButton(
            child: PrettyText(context.localeString(GeneralStrings.close)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
