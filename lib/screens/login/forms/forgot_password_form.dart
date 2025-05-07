// ignore_for_file: use_build_context_synchronously // * Taken care of inside function, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_types/index.dart';
import '../../../global_widgets/index.dart';
import '../../../state/event_status/event_provider.dart';
import '../../../state/firebase/firebase_provider.dart';
import '../../../strings/login/index.dart';
import '../helpers/form_helpers.dart';
import '../types.dart';
import '../widgets/text_field.dart';

const double _margin = 15;

class ForgotPasswordForm extends StatefulHookConsumerWidget {
  const ForgotPasswordForm({
    super.key,
    required this.email,
  });

  final String email;

  @override
  ConsumerState<ForgotPasswordForm> createState() => _ForgotPasswordForm();
}

class _ForgotPasswordForm extends ConsumerState<ForgotPasswordForm> {
  final formKey = GlobalKey<FormState>();

  String email = '';

  // * ================== Controllers ================

  final emailController = TextEditingController();

  void controllerListener() {
    setState(() {
      email = emailController.text;
    });
  }

  @override
  void initState() {
    super.initState();
    email = widget.email;
    emailController.value = TextEditingValue(text: email);
    emailController.addListener(controllerListener);
  }

  void clearFields() {
    emailController.clear();
  }

  // * ================== View ==================

  @override
  Widget build(BuildContext context) {
    final eventStatusNotifier = ref.watch(eventProvider.notifier);
    final firebaseNotifier = ref.watch(firebaseAuthProvider.notifier);

    return Form(
      key: formKey,
      child: Column(
        children: [
          LoginTextField(
            controller: emailController,
            fieldType: FieldType.email,
            validator: (value) => emailValidator(value, context),
            initialValue: email,
          ),
          const SizedBox(height: _margin),
          TbTextButton(
            onPressed: () async {
              // * Validate form
              final success = formKey.currentState!.validate();
              if (!success) {
                return;
              }
              eventStatusNotifier.showLoading();

              // * Login or create account
              ErrorInfo? error;
              error = await firebaseNotifier.resetPassword(email: email);

              // * Message handling
              final messageType = error != null ? error.$1 : MessageType.success;
              final message = error != null ? error.$2 : context.localeString(ForgotPasswordScreenStrings.passwordResetEmailSent);
              eventStatusNotifier.hideLoading();
              eventStatusNotifier.showMessage(
                messageType: messageType,
                message: message,
                title: messageType.name,
                duration: const Duration(seconds: 5),
              );

              // * Clear fields if no error and pop context
              if (error == null) {
                clearFields();
              }
            },
            text: context.localeString(ForgotPasswordScreenStrings.requestPasswordReset),
          ),
          const SizedBox(height: _margin),
        ],
      ),
    );
  }
}
