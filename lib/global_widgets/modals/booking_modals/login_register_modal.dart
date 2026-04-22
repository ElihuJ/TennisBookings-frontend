import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../screens/login/email_login_screen.dart';
import '../../../screens/login/login_screen.dart';
import '../../../screens/login/types.dart';
import '../../../strings/index.dart';
import '../../../theme/colors.dart';
import '../widget/modal_shell.dart';

class LoginRegisterModal extends StatelessWidget {
  const LoginRegisterModal({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalShell(
      icon: Icons.sports_tennis,
      title: context.localeString(BookingModalStrings.welcome),
      subtitle: context.localeString(BookingModalStrings.loginToContinue),
      body: const SizedBox.shrink(),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pushNamed(LoginScreen.route),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryGreen,
            side: const BorderSide(color: AppColors.primaryGreen),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(context.localeString(EmailLoginScreenStrings.login)),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pushNamed(EmailLoginScreen.route, arguments: ScreenMode.register),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(context.localeString(EmailLoginScreenStrings.register)),
        ),
      ],
    );
  }
}

void showLoginRegisterModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return LoginRegisterModal();
    },
  );
}

void showOnlyMembersModal({required BuildContext context, String? message}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ModalShell(
        icon: Icons.card_membership_outlined,
        title: context.localeString(BookingModalStrings.membersOnly),
        body: Text(
          message ?? context.localeString(BookingModalStrings.membersOnlyMessage),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF4A5C50), fontSize: 14, height: 1.5),
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
