import 'package:flutter/material.dart';

import '../../global_types/index.dart';
import '../../theme/colors.dart';

class _MessageStyle {
  const _MessageStyle({required this.icon, required this.iconColor, required this.iconBg, required this.accentColor});
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color accentColor;
}

class Message extends StatelessWidget {
  final String title;
  final String message;
  final MessageType messageType;

  const Message({super.key, this.title = '', this.message = '', required this.messageType});

  _MessageStyle get _style {
    switch (messageType) {
      case MessageType.success:
        return const _MessageStyle(
          icon: Icons.check_circle_outline_rounded,
          iconColor: AppColors.courtGreen,
          iconBg: AppColors.mintLight,
          accentColor: AppColors.courtGreen,
        );
      case MessageType.error:
        return const _MessageStyle(
          icon: Icons.error_outline_rounded,
          iconColor: AppColors.errorRed,
          iconBg: AppColors.errorRedBg,
          accentColor: AppColors.errorRed,
        );
      case MessageType.warning:
        return const _MessageStyle(
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.warningOrange,
          iconBg: AppColors.warningOrangeBg,
          accentColor: AppColors.warningOrange,
        );
      case MessageType.info:
        return const _MessageStyle(
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.infoBlue,
          iconBg: AppColors.infoBlueBg,
          accentColor: AppColors.infoBlue,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;

    return Container(
      color: AppColors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: AppColors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: s.iconBg, shape: BoxShape.circle),
                child: Icon(s.icon, color: s.iconColor, size: 34),
              ),
              if (title.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ],
              if (message.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textBody, height: 1.45),
                ),
              ],
              const SizedBox(height: 20),
              Container(
                height: 3,
                width: 48,
                decoration: BoxDecoration(
                  color: s.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageWithAction extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onPressed;
  final String buttonText;

  const MessageWithAction({super.key, this.title = '', this.message = '', this.onPressed, this.buttonText = 'OK'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: AppColors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(color: AppColors.mintLight, shape: BoxShape.circle),
                child: const Icon(Icons.system_update_outlined, color: AppColors.courtGreen, size: 32),
              ),
              if (title.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ],
              if (message.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textBody, height: 1.45),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.courtGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
