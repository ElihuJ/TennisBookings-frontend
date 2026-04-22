import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../../../../global_widgets/index.dart';
import '../../../../../../strings/index.dart';
import '../../../../../../theme/index.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final void Function()? onSave;

  const ActionButtons({
    super.key,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TbTextButton(
          onPressed: onCancel,
          color: AppColors.grey,
          text: context.localeString(ProfileStrings.discardChanges),
        ),
        const SizedBox(width: 16),
        TbTextButton(
          onPressed: onSave,
          text: context.localeString(ProfileStrings.saveChanges),
        ),
      ],
    );
  }
}
