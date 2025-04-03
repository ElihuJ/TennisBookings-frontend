import 'package:flutter/material.dart';

import '../../theme/index.dart';
import '../index.dart';

class LoadingBox extends StatelessWidget {
  final String title;
  final String message;

  const LoadingBox({super.key, this.title = '', this.message = ''});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.bodyLarge;
    final messageStyle = Theme.of(context).textTheme.bodySmall;

    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title.isNotEmpty) PrettyText(title, style: titleStyle, textAlign: TextAlign.center),
              if (message.isNotEmpty) const SizedBox(height: 20.0),
              if (message.isNotEmpty) PrettyText(message, style: messageStyle, textAlign: TextAlign.center),
              const SizedBox(height: 20.0),
              const CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
