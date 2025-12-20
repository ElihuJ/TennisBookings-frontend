import 'package:flutter/material.dart';
import 'package:tennisbookings/screens/login/widgets/containers.dart';

import '../../assets/index.dart';
import '../../global_widgets/index.dart';
import 'forms/login_register_form.dart';
import 'types.dart';
import 'widgets/footer.dart';
import 'widgets/welcome_header.dart';

class EmailLoginScreen extends StatefulWidget {
  static const route = 'LoginRegisterEmail';
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
      _screenMode = _screenMode == ScreenMode.login ? ScreenMode.register : ScreenMode.login;
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
    return TbScaffold(
      body: EventfulWidget(
        child: ContainerWithBackground(
          imagePath: homeBackgroundPng,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              WelcomeHeader(isLogin: isLogin),
              LoginRegisterForm(isLogin: isLogin, email: _email, updateEmail: updateEmail),
              Footer(isLogin: isLogin, toggleScreenMode: toggleScreenMode, screenMode: _screenMode, email: _email)
            ],
          ),
        ),
      ),
    );
  }
}
