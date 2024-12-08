import 'package:flutter/material.dart';

import '../../../global_helpers/layout.dart';
import '../../../theme/index.dart';

class BackArrow extends StatelessWidget {
  const BackArrow({super.key, this.padding});

  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          EdgeInsets.only(
            top: heightPercent(percentage: 5, context),
            left: widthPercent(percentage: 5, context),
          ),
      child: InkWell(
        onTap: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushNamed(context, '/');
          }
        },
        child: const Icon(
          Icons.arrow_circle_left_outlined,
          size: 60,
          color: AppColors.black,
        ),
      ),
    );
  }
}
