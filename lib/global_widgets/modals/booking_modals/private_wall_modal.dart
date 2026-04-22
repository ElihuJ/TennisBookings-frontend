import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../strings/index.dart';
import '../../../theme/colors.dart';
import '../widget/modal_shell.dart';

void showPrivateWallModal({required BuildContext context, String? message}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ModalShell(
        icon: Icons.lock_outline,
        title: context.localeString(BookingModalStrings.privateBooking),
        body: Text(
          message ?? context.localeString(BookingModalStrings.privateBookingMessage),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textBody, fontSize: 14, height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(context.localeString(GeneralStrings.close)),
          ),
        ],
      );
    },
  );
}
