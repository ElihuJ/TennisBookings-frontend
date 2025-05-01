import 'package:flutter/material.dart';

import '../../../../../../global_widgets/index.dart';
import '../../../../../../theme/index.dart';
import '../profile_details.dart';

class FieldWithPencil extends StatelessWidget {
  final Function() onTap;
  final Widget child;
  final ProfileDetailsMode mode;

  const FieldWithPencil({
    super.key,
    required this.child,
    required this.onTap,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final smallScreen = screenWidth < 600;

    return Padding(
      padding: smallScreen ? const EdgeInsets.only(right: 20) : const EdgeInsets.only(right: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          mode != ProfileDetailsMode.edit
              ? IconButton(
                  color: AppColors.grey,
                  icon: const Icon(Icons.edit),
                  onPressed: onTap,
                )
              : const SizedBox(width: 40),
          Container(
            width: 200,
            height: 80,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final Function() onCancel;
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TbTextButton(
          onPressed: onCancel,
          color: AppColors.grey,
          text: 'Discard',
        ),
        SizedBox(width: 20),
        TbTextButton(
          onPressed: onSave,
          text: 'Save\nchanges',
        ),
      ],
    );
  }
}
