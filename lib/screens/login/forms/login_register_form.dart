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
import '../../../state/index.dart';
import '../../../strings/login/index.dart';
import '../../../theme/colors.dart';
import '../../home_screen.dart';
import '../helpers/form_helpers.dart';
import '../helpers/helper.dart';
import '../types.dart';
import '../widgets/text_field.dart';

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

  @override
  Widget build(BuildContext context) {
    final isLogin = widget.isLogin;
    final eventStatusNotifier = ref.read(eventProvider.notifier);
    final firebaseNotifier = ref.read(firebaseAuthProvider.notifier);
    final userNotifier = ref.read(userProvider.notifier);
    final eventNotifier = ref.read(eventProvider.notifier);

    void onSubmit() async {
      bool success = formKey.currentState!.validate();
      if (!success) return;

      eventStatusNotifier.showLoading(
        message: isLogin
            ? context.localeString(EmailLoginScreenStrings.loggingIn)
            : context.localeString(EmailLoginScreenStrings.creatingAccount),
      );

      ErrorInfo? errorInfo;
      fb_auth.User? user;

      if (isLogin) {
        errorInfo = await firebaseNotifier.login(email: widget.email, password: password);
      } else {
        (user, errorInfo) = await firebaseNotifier.createAccount(email: widget.email, password: password);
      }

      if (errorInfo == null) {
        clearFields();
        if (!isLogin && user != null) {
          (success, errorInfo) = await userNotifier.createUser(name: user.displayName, uid: user.uid, email: user.email);
        }
      }

      final messageType = errorInfo != null ? errorInfo.$1 : MessageType.success;
      final message = errorInfo != null
          // ignore: use_build_context_synchronously
          ? context.localeString(errorInfo.$2)
          : isLogin
              // ignore: use_build_context_synchronously
              ? context.localeString(EmailLoginScreenStrings.loginToYourAccount)
              // ignore: use_build_context_synchronously
              : context.localeString(EmailLoginScreenStrings.verificationEmailSent);
      eventStatusNotifier.hideLoading();

      if (isLogin && errorInfo == null && context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, HomeScreen.route, (route) => false);
        return;
      }

      eventStatusNotifier.showMessage(
        messageType: messageType,
        title: messageType.name,
        message: message,
      );
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            FilledButton(
              onPressed: onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isLogin ? context.localeString(EmailLoginScreenStrings.login) : context.localeString(EmailLoginScreenStrings.createAccount),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            if (!isLogin) ...[
              const SizedBox(height: 20),
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
              SocialsRegister(
                eventNotifier: eventNotifier,
                firebaseNotifier: firebaseNotifier,
                userNotifier: userNotifier,
              ),
            ],
            const SizedBox(height: 8),
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

  final EventNotifier eventNotifier;
  final FirebaseAuthNotifier firebaseNotifier;
  final UserNotifier userNotifier;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
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
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey.shade300),
        foregroundColor: Colors.black87,
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(googleSvg, width: 20, height: 20),
          const SizedBox(width: 10),
          Text(
            context.localeString(LoginScreenStrings.loginWithGoogle),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
