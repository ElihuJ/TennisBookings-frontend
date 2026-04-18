import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../strings/index.dart';
import '../../index.dart';

class GeneralForbiddenModal extends StatelessWidget {
  const GeneralForbiddenModal({super.key, this.title, this.message});
  final String? title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TitleText(
        title ?? context.localeString(GeneralStrings.notAllowed),
        textAlign: TextAlign.center,
      ),
      content: PrettyText(
        message ?? '',
      ),
    );
  }
}

void showGeneralForbiddenModal(BuildContext context, {String? title, String? message}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return GeneralForbiddenModal(title: title, message: message);
    },
  );
}
