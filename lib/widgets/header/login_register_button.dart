import 'package:flutter/material.dart';

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
          onPressed: () {},
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
          onPressed: () {},
          child: Text(
            'Register',
            style: TextStyle(color: AppColors.white),
          ),
        ),
      ],
    );
  }
}
