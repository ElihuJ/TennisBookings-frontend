import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../assets/index.dart';
import '../../global_widgets/buttons/login_button.dart';
import '../../global_widgets/eventful/eventful.dart';
import '../../global_widgets/header/index.dart';
import '../../state/index.dart';
import '../../strings/index.dart';
import 'email_login_screen.dart';
import 'forms/login_register_form.dart';
import 'types.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});
  static const route = 'Login';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseAuthNotifier = ref.read(firebaseAuthProvider.notifier);
    final userNotifier = ref.read(userProvider.notifier);
    final eventNotifier = ref.read(eventStatusProvider.notifier);

    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: Scaffold(
            appBar: Header(),
            body: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      logoPgn,
                      width: 300,
                    ),
                  ),
                  // ^ ================== GOOGLE LOGIN ==================
                  Column(
                    children: [
                      SocialsRegister(
                        eventNotifier: eventNotifier,
                        firebaseNotifier: firebaseAuthNotifier,
                        userNotifier: userNotifier,
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        // ^ ================== EMAIL LOGIN ==================
                        child: LoginButton(
                          onTap: () {
                            // * Handle email login
                            Navigator.pushNamed(context, EmailLoginScreen.route, arguments: ScreenMode.login);
                          },
                          text: context.localeString(LoginScreenStrings.loginWithEmail),
                          icon: const Icon(Icons.email),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
