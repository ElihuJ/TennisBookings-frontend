import 'package:flutter/material.dart';

import '../../../helpers/index.dart';
import '../../../theme/colors.dart';
import '../../../widgets/eventful/eventful.dart';
import '../../../widgets/header/index.dart';
import 'forms/login_sign_up_form.dart';
import 'types.dart';
import 'widgets/footer.dart';
import 'widgets/welcome_header.dart';

class EmailLoginScreen extends StatefulWidget {
  static const route = 'LoginSignupEmail';

  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => EmailLoginScreenState();
}

class EmailLoginScreenState extends State<EmailLoginScreen> {
  ScreenMode _screenMode = ScreenMode.login;

  String _email = '';
  bool get isLogin => _screenMode == ScreenMode.login;

  void toggleScreenMode() {
    setState(() {
      _screenMode = _screenMode == ScreenMode.login
          ? ScreenMode.signUp
          : ScreenMode.login;
    });
  }

  void updateEmail({required String newEmail}) {
    setState(() {
      _email = newEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      backgroundColor: AppColors.almostWhite,
      body: EventfulWidget(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: widthPercent(percentage: 30, context),
              vertical: heightPercent(percentage: 1, context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              WelcomeHeader(isLogin: isLogin),
              LoginSignupForm(
                  isLogin: isLogin, email: _email, updateEmail: updateEmail),
              Footer(
                  isLogin: isLogin,
                  toggleScreenMode: toggleScreenMode,
                  screenMode: _screenMode,
                  email: _email)
            ],
          ),
        ),
      ),
    );
  }
}
