import 'package:flutter/material.dart';

import '../../theme/index.dart';

BoxDecoration borderedBoxDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    color: AppColors.white,
    border: Border.all(
      color: AppColors.primaryGreen,
      width: 1,
    ),
  );
}
