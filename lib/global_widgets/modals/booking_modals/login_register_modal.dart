import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../screens/login/email_login_screen.dart';
import '../../../screens/login/login_screen.dart';
import '../../../screens/login/types.dart';
import '../../../strings/index.dart';
import '../../../theme/index.dart';
import '../../index.dart';

class LoginRegisterModal extends StatelessWidget {
  const LoginRegisterModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: PrettyText(context.localeString(BookingModalStrings.welcome)),
      content: PrettyText(context.localeString(BookingModalStrings.loginToContinue)),
      actions: <Widget>[
        TbTextButton(
          text: context.localeString(EmailLoginScreenStrings.login),
          onPressed: () => Navigator.of(context).pushNamed(LoginScreen.route),
          color: AppColors.secondaryGreen,
        ),
        TbTextButton(
          text: context.localeString(EmailLoginScreenStrings.register),
          color: AppColors.darkGreen,
          onPressed: () => Navigator.of(context).pushNamed(EmailLoginScreen.route, arguments: ScreenMode.register),
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
      return AlertDialog(
        title: TitleText(context.localeString(BookingModalStrings.membersOnly), textAlign: TextAlign.center),
        content: PrettyText(message ?? context.localeString(BookingModalStrings.membersOnlyMessage)),
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
