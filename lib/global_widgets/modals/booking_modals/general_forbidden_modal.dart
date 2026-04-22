import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../strings/index.dart';
import '../../../theme/colors.dart';
import '../widget/modal_shell.dart';

class GeneralForbiddenModal extends StatelessWidget {
  const GeneralForbiddenModal({super.key, this.title, this.message});
  final String? title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return ModalShell(
      icon: Icons.block_outlined,
      title: title ?? context.localeString(GeneralStrings.notAllowed),
      body: message != null && message!.isNotEmpty
          ? Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textBody, fontSize: 14, height: 1.5),
            )
          : const SizedBox.shrink(),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(context.localeString(GeneralStrings.close)),
        ),
      ],
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
