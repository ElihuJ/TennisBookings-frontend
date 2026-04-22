import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../global_widgets/index.dart';
import '../../state/index.dart';
import '../../strings/login/index.dart';
import '../../theme/colors.dart';
import 'email_login_screen.dart';
import 'forms/login_register_form.dart';
import 'types.dart';
import 'widgets/containers.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});
  static const route = 'Login';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseAuthNotifier = ref.read(firebaseAuthProvider.notifier);
    final userNotifier = ref.read(userProvider.notifier);
    final eventNotifier = ref.read(eventProvider.notifier);

    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: TbScaffold(
          body: ContainerWithBackground(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 20,
                    shadowColor: Colors.black.withValues(alpha: 0.25),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Gradient hero with logo
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primaryGreen, AppColors.darkGreen],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                          child: Column(
                            children: [
                              TbLogoWhite(width: 200),
                              const SizedBox(height: 20),
                              Text(
                                context.localeString(EmailLoginScreenStrings.welcomeBack),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        // Buttons section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
                          child: Column(
                            children: [
                              SocialsRegister(
                                eventNotifier: eventNotifier,
                                firebaseNotifier: firebaseAuthNotifier,
                                userNotifier: userNotifier,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey.shade300)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      context.localeString(EmailLoginScreenStrings.orContinueWith),
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey.shade300)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  EmailLoginScreen.route,
                                  arguments: ScreenMode.login,
                                ),
                                icon: const Icon(Icons.email_outlined, size: 20),
                                label: Text(context.localeString(LoginScreenStrings.loginWithEmail)),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  side: BorderSide(color: AppColors.primaryGreen.withValues(alpha: 0.5)),
                                  foregroundColor: AppColors.primaryGreen,
                                  backgroundColor: Colors.white,
                                ),
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
      ),
    );
  }
}
