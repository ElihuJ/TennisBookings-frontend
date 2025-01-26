// ignore_for_file: // * Taken care of inside function,, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../assets/index.dart';
import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../global_widgets/index.dart';
import '../../../state/index.dart';
import '../../../strings/login/index.dart';
import '../../home_screen.dart';
import '../helpers/form_helpers.dart';
import '../helpers/helper.dart';
import '../types.dart';
import '../widgets/text_field.dart';

const double _margin = 15;

class LoginRegisterForm extends StatefulHookConsumerWidget {
  const LoginRegisterForm({
    super.key,
    required this.isLogin,
    required this.email,
    required this.updateEmail,
  });

  final bool isLogin;
  final String email;
  final void Function({required String newEmail}) updateEmail;

  @override
  ConsumerState<LoginRegisterForm> createState() => _LoginRegisterFormState();
}

class _LoginRegisterFormState extends ConsumerState<LoginRegisterForm> {
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
    final eventStatusNotifier = ref.read(eventsProvider.notifier);
    final firebaseNotifier = ref.read(firebaseAuthProvider.notifier);
    final userNotifier = ref.read(userProvider.notifier);
    final eventNotifier = ref.read(eventsProvider.notifier);

    void onSubmit() async {
      bool success = formKey.currentState!.validate();
      if (!success) {
        return;
      }
      eventStatusNotifier.showLoading(
          message: isLogin ? context.localeString(EmailLoginScreenStrings.loggingIn) : context.localeString(EmailLoginScreenStrings.creatingAccount));

      // * Login or create account
      ErrorInfo? errorInfo;
      fb_auth.User? user;

      if (isLogin) {
        errorInfo = await firebaseNotifier.login(email: widget.email, password: password);
      } else {
        (user, errorInfo) = await firebaseNotifier.createAccount(email: widget.email, password: password);
      }

      // * Clear fields if no errorInfo
      if (errorInfo == null) {
        clearFields();
        if (!isLogin && user != null) {
          (success, errorInfo) = await userNotifier.createUser(name: user.displayName, uid: user.uid, email: user.email);
        }
      }

      // * Message handling

      final messageType = errorInfo != null ? errorInfo.$1 : MessageType.success;
      final message = errorInfo != null
          ? context.localeString(errorInfo.$2)
          : isLogin
              ? context.localeString(EmailLoginScreenStrings.loginToYourAccount)
              : context.localeString(EmailLoginScreenStrings.verificationEmailSent);
      showToast(
        context: context,
        messageType: messageType,
        message: message,
      );

      eventStatusNotifier.hideLoading();

      if (isLogin && errorInfo == null && context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, HomeScreen.route, (route) => false);
      }
    }

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (key) {
        if (key.logicalKey == LogicalKeyboardKey.enter) {
          FocusScope.of(context).unfocus();
          onSubmit();
        }
      },
      child: Form(
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
            LoginTextField(
              controller: passwordController,
              fieldType: FieldType.password,
              validator: (value) => passwordValidator(value, context),
            ),
            if (!isLogin)
              LoginTextField(
                controller: confirmPasswordController,
                fieldType: FieldType.confirmPassword,
                validator: (value) => confirmPasswordValidator(value, password, context),
              ),
            TbTextButton(
              text: (isLogin ? context.localeString(EmailLoginScreenStrings.login) : context.localeString(EmailLoginScreenStrings.createAccount)),
              onPressed: onSubmit,
            ),
            const SizedBox(height: _margin),
            if (!isLogin)
              Column(
                children: [
                  Text(context.localeString(EmailLoginScreenStrings.orContinueWith)),
                  const SizedBox(height: _margin),
                  SocialsRegister(eventNotifier: eventNotifier, firebaseNotifier: firebaseNotifier, userNotifier: userNotifier),
                ],
              )
          ],
        ),
      ),
    );
  }
}

class SocialsRegister extends StatelessWidget {
  const SocialsRegister({
    super.key,
    required this.eventNotifier,
    required this.firebaseNotifier,
    required this.userNotifier,
  });

  final EventStatusNotifier eventNotifier;
  final FirebaseAuthNotifier firebaseNotifier;
  final UserNotifier userNotifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoginButton(
          onTap: () async {
            final resultHandler = ResultHandler();
            await signInWithGoogle(
              context: context,
              eventNotifier: eventNotifier,
              firebaseAuthNotifier: firebaseNotifier,
              userNotifier: userNotifier,
              resultHandler: resultHandler,
            );
            if (resultHandler.error == null && context.mounted) {
              Navigator.pushNamedAndRemoveUntil(context, HomeScreen.route, (route) => false);
            }
          },
          icon: SvgPicture.asset(googleSvg),
          text: context.localeString(LoginScreenStrings.loginWithGoogle),
        ),
      ],
    );
  }
}
