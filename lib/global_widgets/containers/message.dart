import 'package:flutter/material.dart';

import '../../global_types/index.dart';

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
        return _MessageStyle(
          icon: Icons.check_circle_outline_rounded,
          iconColor: const Color(0xFF1F6B4A),
          iconBg: const Color(0xFFDFF0E4),
          accentColor: const Color(0xFF1F6B4A),
        );
      case MessageType.error:
        return _MessageStyle(
          icon: Icons.error_outline_rounded,
          iconColor: const Color(0xFFB71C1C),
          iconBg: const Color(0xFFFFEBEE),
          accentColor: const Color(0xFFB71C1C),
        );
      case MessageType.warning:
        return _MessageStyle(
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFE65100),
          iconBg: const Color(0xFFFFF3E0),
          accentColor: const Color(0xFFE65100),
        );
      case MessageType.info:
        return _MessageStyle(
          icon: Icons.info_outline_rounded,
          iconColor: const Color(0xFF1565C0),
          iconBg: const Color(0xFFE3F2FD),
          accentColor: const Color(0xFF1565C0),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;

    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8)),
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A2E22)),
                ),
              ],
              if (message.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF4A5C50), height: 1.45),
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
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(color: Color(0xFFDFF0E4), shape: BoxShape.circle),
                child: const Icon(Icons.system_update_outlined, color: Color(0xFF1F6B4A), size: 32),
              ),
              if (title.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A2E22)),
                ),
              ],
              if (message.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF4A5C50), height: 1.45),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1F6B4A),
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
