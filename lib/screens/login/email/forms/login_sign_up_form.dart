// ignore_for_file: // * Taken care of inside function,, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../state/index.dart';
import '../../../../strings/login/index.dart';
import '../../../../types/index.dart';
import '../../../../widgets/buttons/standard_buttons.dart';
import '../../../../widgets/index.dart';
import '../../../home_screen.dart';
import '../helpers/form_helpers.dart';
import '../types.dart';
import '../widgets/text_field.dart';

const double _margin = 50;

class LoginSignupForm extends StatefulHookConsumerWidget {
  const LoginSignupForm({
    super.key,
    required this.isLogin,
    required this.email,
    required this.updateEmail,
  });

  final bool isLogin;
  final String email;
  final void Function({required String newEmail}) updateEmail;

  @override
  ConsumerState<LoginSignupForm> createState() => _LoginSignupFormState();
}

class _LoginSignupFormState extends ConsumerState<LoginSignupForm> {
  final formKey = GlobalKey<FormState>();

  String password = '';
  String confirmPassword = '';

  // * ================== Controllers ================

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void controllerListener() {
    setState(() {
      widget.updateEmail(newEmail: emailController.text);
      password = passwordController.text;
      confirmPassword = confirmPasswordController.text;
    });
  }

  @override
  void initState() {
    super.initState();
    emailController.addListener(controllerListener);
    passwordController.addListener(controllerListener);
    confirmPasswordController.addListener(controllerListener);
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  // * ================== View ==================

  @override
  Widget build(BuildContext context) {
    final isLogin = widget.isLogin;
    final eventStatusNotifier = ref.read(eventStatusProvider.notifier);
    final firebaseNotifier = ref.read(firebaseAuthProvider.notifier);
    final userNotifier = ref.read(userProvider.notifier);

    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LoginTextField(
            controller: emailController,
            fieldType: FieldType.email,
            validator: (value) => emailValidator(value, context),
          ),
          SizedBox(height: _margin / 3),
          LoginTextField(
            controller: passwordController,
            fieldType: FieldType.password,
            validator: (value) => passwordValidator(value, context),
          ),
          if (!isLogin)
            Column(
              children: [
                SizedBox(height: _margin / 3),
                LoginTextField(
                  controller: confirmPasswordController,
                  fieldType: FieldType.confirmPassword,
                  validator: (String? value) =>
                      confirmPasswordValidator(value, password, context),
                ),
              ],
            ),
          const SizedBox(height: _margin),
          TbTextButton(
            text: (isLogin
                ? context.localeString(EmailLoginScreenStrings.login)
                : context.localeString(EmailLoginScreenStrings.createAccount)),
            onPressed: () async {
              // * Validate form
              bool success = formKey.currentState!.validate();
              if (!success) {
                return;
              }
              eventStatusNotifier.showLoading(
                  message: isLogin
                      ? context.localeString(EmailLoginScreenStrings.loggingIn)
                      : context.localeString(
                          EmailLoginScreenStrings.creatingAccount));

              // * Login or create account
              ErrorInfo? errorInfo;
              fb_auth.User? user;

              if (isLogin) {
                errorInfo = await firebaseNotifier.login(
                    email: widget.email, password: password);
              } else {
                (user, errorInfo) = await firebaseNotifier.createAccount(
                    email: widget.email, password: password);
              }

              // * Clear fields if no errorInfo
              if (errorInfo == null) {
                clearFields();
                FocusManager.instance.primaryFocus
                    ?.unfocus(); // * Hide keyboard
                if (!isLogin && user != null) {
                  (success, errorInfo) = await userNotifier.createUser(
                      name: user.displayName, uid: user.uid, email: user.email);
                }
              }

              // * Message handling

              final messageType =
                  errorInfo != null ? errorInfo.$1 : MessageType.success;
              final message = errorInfo != null
                  ? context.localeString(errorInfo.$2)
                  : isLogin
                      ? context.localeString(
                          EmailLoginScreenStrings.loginToYourAccount)
                      : context.localeString(
                          EmailLoginScreenStrings.verificationEmailSent);
              showToast(
                context: context,
                messageType: messageType,
                message: message,
              );

              eventStatusNotifier.hideLoading();

              if (isLogin && errorInfo == null && context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, HomeScreen.route, (route) => false);
              }
            },
          ),
          const SizedBox(height: _margin),
        ],
      ),
    );
  }
}
