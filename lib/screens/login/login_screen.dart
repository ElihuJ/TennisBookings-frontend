import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/widgets/buttons/login_button.dart';

import '../../assets/icons.dart';
import '../../helpers/index.dart';
import '../../state/index.dart';
import '../../strings/index.dart';
import '../../widgets/eventful/eventful.dart';
import '../../widgets/header/index.dart';
import 'helper.dart';

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoginButton(
                    onTap: () async {
                      final resultHandler = ResultHandler();
                      await signInWithGoogle(
                        context: context,
                        eventNotifier: eventNotifier,
                        firebaseAuthNotifier: firebaseAuthNotifier,
                        userNotifier: userNotifier,
                        resultHandler: resultHandler,
                      );
                      if (resultHandler.error == null) {
                        // Navigator.pushNamedAndRemoveUntil(context, HomeScreen.route, (route) => false);
                      }
                    },
                    icon: SvgPicture.asset(googleSvg),
                    text: context.localeString(LoginScreenStrings.loginWithGoogle),
                  ),
                  SizedBox(height: 16),
                  // ElevatedButton.icon(
                  //   onPressed: () {
                  //     // Handle Email login
                  //   },
                  //   icon: Icon(Icons.email),
                  //   label: Text('Login with Email'),
                  // ),
                ],
              ),
            )),
      ),
    );
  }
}
