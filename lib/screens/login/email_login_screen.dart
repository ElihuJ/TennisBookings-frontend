import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../global_widgets/index.dart';
import '../../strings/login/index.dart';
import '../../theme/colors.dart';
import 'forms/login_register_form.dart';
import 'types.dart';
import 'widgets/containers.dart';
import 'widgets/footer.dart';

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  elevation: 20,
                  shadowColor: Colors.black.withValues(alpha: 0.25),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LoginHero(isLogin: isLogin),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                        child: Column(
                          children: [
                            LoginRegisterForm(
                              isLogin: isLogin,
                              email: _email,
                              updateEmail: updateEmail,
                            ),
                            Footer(
                              isLogin: isLogin,
                              toggleScreenMode: toggleScreenMode,
                              screenMode: _screenMode,
                              email: _email,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero({required this.isLogin});

  final bool isLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            ),
            child: Icon(
              isLogin ? Icons.person_outline : Icons.person_add_outlined,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isLogin
                ? context.localeString(EmailLoginScreenStrings.login)
                : context.localeString(EmailLoginScreenStrings.register),
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            isLogin
                ? context.localeString(EmailLoginScreenStrings.welcomeBack)
                : context.localeString(EmailLoginScreenStrings.justAFewThings),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
