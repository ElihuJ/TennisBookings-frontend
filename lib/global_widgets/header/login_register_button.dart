import 'package:flutter/material.dart';
import 'package:tennisbookings/global_widgets/index.dart';
import 'package:tennisbookings/theme/index.dart';

import '../../screens/login/email_login_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/login/types.dart';

class LoginRegisterButton extends StatelessWidget {
  const LoginRegisterButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TbTextButton(
          onPressed: () => Navigator.of(context).pushNamed(LoginScreen.route),
          text: 'Login',
          color: AppColors.secondaryGreen,
        ),
        const SizedBox(width: 10),
        TbTextButton(
          color: AppColors.darkGreen,
          onPressed: () => Navigator.of(context).pushNamed(EmailLoginScreen.route, arguments: ScreenMode.register),
          text: 'Register',
        ),
      ],
    );
  }
}
