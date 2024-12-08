import 'package:flutter/material.dart';

import '../../global_helpers/index.dart';
import '../../global_widgets/eventful/eventful.dart';
import '../../global_widgets/header/index.dart';
import '../../theme/colors.dart';
import 'forms/login_sign_up_form.dart';
import 'types.dart';
import 'widgets/footer.dart';
import 'widgets/welcome_header.dart';

class EmailLoginScreen extends StatefulWidget {
  static const route = 'LoginSignupEmail';
  final ScreenMode screenMode;

  const EmailLoginScreen({super.key, required this.screenMode});

  @override
  State<EmailLoginScreen> createState() => EmailLoginScreenState();
}

class EmailLoginScreenState extends State<EmailLoginScreen> {
  String _email = '';
  ScreenMode _screenMode = ScreenMode.login;

  @override
  void initState() {
    super.initState();
    _screenMode = widget.screenMode;
  }

  void toggleScreenMode() {
    setState(() {
      _screenMode = _screenMode == ScreenMode.login ? ScreenMode.signUp : ScreenMode.login;
    });
  }

  void updateEmail({required String newEmail}) {
    setState(() {
      _email = newEmail;
    });
  }

  bool get isLogin => _screenMode == ScreenMode.login;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      backgroundColor: AppColors.almostWhite,
      body: EventfulWidget(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: widthPercent(percentage: 30, context), vertical: heightPercent(percentage: 1, context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              WelcomeHeader(isLogin: isLogin),
              LoginSignupForm(isLogin: isLogin, email: _email, updateEmail: updateEmail),
              Footer(isLogin: isLogin, toggleScreenMode: toggleScreenMode, screenMode: _screenMode, email: _email)
            ],
          ),
        ),
      ),
    );
  }
}
