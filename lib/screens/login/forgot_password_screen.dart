import 'package:flutter/material.dart';

import '../../global_helpers/index.dart';
import '../../global_widgets/containers/bordered_box.dart';
import '../../global_widgets/eventful/eventful.dart';
import '../../global_widgets/header/index.dart';
import '../../theme/colors.dart';
import 'forms/forgot_password_form.dart';
import 'widgets/back_arrow.dart';
import 'widgets/forgot_password_header.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const route = 'ForgotPassword';

  const ForgotPasswordScreen({super.key, required this.email});

  final String email;

  @override
  State<ForgotPasswordScreen> createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return EventfulWidget(
      child: Scaffold(
        backgroundColor: AppColors.almostWhite,
        appBar: const Header(),
        body: BorderedBox(
          borderColor: AppColors.secondaryGreen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackArrow(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widthPercent(percentage: 35, context),
                  vertical: heightPercent(percentage: 10, context),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const ForgotPasswordHeader(),
                    ForgotPasswordForm(
                      email: widget.email,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
