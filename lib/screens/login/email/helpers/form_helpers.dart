import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../../strings/login/index.dart';

String? emailValidator(String? value, BuildContext context) {
  if (value == null || value.isEmpty) {
    return context.localeString(LoginSignupValidatorStrings.emailRequired);
  }
  // Use regex to verify email format
  final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!regex.hasMatch(value)) {
    return context.localeString(LoginSignupValidatorStrings.emailInvalid);
  }
  return null;
}

String? passwordValidator(String? value, BuildContext context) {
  if (value == null || value.isEmpty) {
    return context.localeString(LoginSignupValidatorStrings.passwordRequired);
  }
  if (value.length < 6) {
    return context.localeString(LoginSignupValidatorStrings.passwordInvalid);
  }
  return null;
}

String? confirmPasswordValidator(String? value, String password, BuildContext context) {
  if (value == null || value.isEmpty) {
    return context.localeString(LoginSignupValidatorStrings.confirmPasswordRequired);
  }
  if (value != password) {
    return context.localeString(LoginSignupValidatorStrings.confirmPasswordInvalid);
  }
  return null;
}
