import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../../strings/login/index.dart';
import '../../../../theme/colors.dart';
import '../types.dart';

const double _margin = 15;

class LoginTextField extends StatelessWidget {
  const LoginTextField(
      {super.key, required this.controller, required this.fieldType, required this.validator, this.initialValue});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: _margin),
      padding: const EdgeInsets.only(left: 10, top: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.white),
      child: TextFormField(
        keyboardType: fieldType == FieldType.email ? TextInputType.emailAddress : TextInputType.text,
        autocorrect: false,
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          hintText: context.localeString(fieldName),
          isDense: false,
        ),
        obscureText: obscureText,
      ),
    );
  }
}
