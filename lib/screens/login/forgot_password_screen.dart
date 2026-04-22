import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../global_widgets/index.dart';
import '../../strings/login/index.dart';
import '../../theme/colors.dart';
import 'forms/forgot_password_form.dart';
import 'widgets/containers.dart';

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
      child: TbScaffold(
        body: ContainerWithBackground(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  elevation: 20,
                  shadowColor: Colors.black.withValues(alpha: 0.25),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Gradient hero
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryGreen, AppColors.darkGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.15),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                              ),
                              child: const Icon(Icons.lock_open_outlined, color: Colors.white, size: 34),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.localeString(ForgotPasswordScreenStrings.title),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.localeString(ForgotPasswordScreenStrings.description),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      // Form section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                        child: Column(
                          children: [
                            ForgotPasswordForm(email: widget.email),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                if (Navigator.canPop(context)) Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back, size: 16),
                              label: Text(context.localeString(EmailLoginScreenStrings.login)),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryGreen,
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
