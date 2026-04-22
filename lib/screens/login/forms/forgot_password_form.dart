// ignore_for_file: use_build_context_synchronously // * Taken care of inside function, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_types/index.dart';
import '../../../state/event_status/event_provider.dart';
import '../../../state/firebase/firebase_provider.dart';
import '../../../strings/login/index.dart';
import '../../../theme/colors.dart';
import '../helpers/form_helpers.dart';
import '../types.dart';
import '../widgets/text_field.dart';

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

  @override
  Widget build(BuildContext context) {
    final eventStatusNotifier = ref.watch(eventProvider.notifier);
    final firebaseNotifier = ref.watch(firebaseAuthProvider.notifier);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LoginTextField(
            controller: emailController,
            fieldType: FieldType.email,
            validator: (value) => emailValidator(value, context),
            initialValue: email,
          ),
          const SizedBox(height: 4),
          FilledButton(
            onPressed: () async {
              final success = formKey.currentState!.validate();
              if (!success) return;
              eventStatusNotifier.showLoading();

              ErrorInfo? error;
              error = await firebaseNotifier.resetPassword(email: email);

              final messageType = error != null ? error.$1 : MessageType.success;
              final message = error != null ? error.$2 : context.localeString(ForgotPasswordScreenStrings.passwordResetEmailSent);
              eventStatusNotifier.hideLoading();
              eventStatusNotifier.showMessage(
                messageType: messageType,
                message: message,
                title: messageType.name,
              );

              if (error == null) clearFields();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              context.localeString(ForgotPasswordScreenStrings.requestPasswordReset),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
