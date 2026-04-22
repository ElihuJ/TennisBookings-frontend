import 'package:flutter/material.dart';

import '../../theme/index.dart';

class LoadingBox extends StatelessWidget {
  final String title;
  final String message;

  const LoadingBox({super.key, this.title = '', this.message = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          width: 260,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
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
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                    strokeWidth: 3,
                  ),
                ),
              ),
              if (title.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A2E22)),
                ),
              ],
              if (message.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF4A5C50), height: 1.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
