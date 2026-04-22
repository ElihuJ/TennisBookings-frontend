import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../strings/login/index.dart';
import '../../../theme/colors.dart';
import '../types.dart';

class LoginTextField extends StatelessWidget {
  const LoginTextField({
    super.key,
    required this.controller,
    required this.fieldType,
    required this.validator,
    this.initialValue,
  });

  final TextEditingController controller;
  final FieldType fieldType;
  final String? Function(String?) validator;
  final String? initialValue;

  bool get obscureText => fieldType != FieldType.email;

  String get fieldName {
    switch (fieldType) {
      case FieldType.email:
        return EmailLoginScreenStrings.email;
      case FieldType.password:
        return EmailLoginScreenStrings.password;
      case FieldType.confirmPassword:
        return EmailLoginScreenStrings.confirmPassword;
    }
  }

  IconData get fieldIcon {
    switch (fieldType) {
      case FieldType.email:
        return Icons.email_outlined;
      case FieldType.password:
        return Icons.lock_outline;
      case FieldType.confirmPassword:
        return Icons.lock_open_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        keyboardType: fieldType == FieldType.email ? TextInputType.emailAddress : TextInputType.text,
        autocorrect: false,
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: context.localeString(fieldName),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(fieldIcon, color: AppColors.primaryGreen, size: 20),
          filled: true,
          fillColor: const Color(0xFFF5F7F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
