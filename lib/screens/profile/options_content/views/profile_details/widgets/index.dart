import 'package:flutter/material.dart';
import 'package:tennisbookings/screens/profile/options_content/views/profile_details/profile_details.dart';

import '../../../../../../global_widgets/index.dart';
import '../../../../../../theme/index.dart';

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
    return Padding(
      padding: const EdgeInsets.only(right: 40),
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
  final Function() onSave;

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
        Container(
          width: 160,
          height: 80,
          margin: const EdgeInsets.only(right: 20),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(AppColors.grey),
            ),
            onPressed: onCancel,
            child: PrettyText('Discard'),
          ),
        ),
        SizedBox(
          width: 160,
          height: 80,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(AppColors.primaryGreen),
            ),
            onPressed: onSave,
            child: PrettyText(
              'Save\nchanges',
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
