import 'package:flutter/material.dart';

class GeneralForbiddenModal extends StatelessWidget {
  const GeneralForbiddenModal({super.key, this.title, this.message});
  final String? title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? 'Not allowed'),
      content: Text(message ?? ''),
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
