import 'package:flutter/material.dart';

import '../../screens/login/email_login_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/login/types.dart';
import '../../theme/colors.dart';

class LoginRegisterButton extends StatelessWidget {
  const LoginRegisterButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryGreen,
          ),
          onPressed: () => Navigator.of(context).pushNamed(
            LoginScreen.route,
          ),
          child: Text(
            'Login',
            style: TextStyle(color: AppColors.white),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkGreen,
          ),
          onPressed: () => Navigator.of(context).pushNamed(EmailLoginScreen.route, arguments: ScreenMode.register),
          child: Text(
            'Register',
            style: TextStyle(color: AppColors.white),
          ),
        ),
      ],
    );
  }
}
