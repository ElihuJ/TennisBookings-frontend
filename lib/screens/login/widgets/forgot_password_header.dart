import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../strings/login/index.dart';
import 'text_area.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextArea(
        text: context.localeString(ForgotPasswordScreenStrings.title),
        isTitle: true,
      ),
      TextArea(text: context.localeString(ForgotPasswordScreenStrings.description))
    ]);
  }
}
