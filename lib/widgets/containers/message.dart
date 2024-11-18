import 'package:flutter/material.dart';

import '../../types/index.dart';
import '../index.dart';

class Message extends StatelessWidget {
  final String title;
  final String message;
  final MessageType messageType;

  const Message({super.key, this.title = '', this.message = '', required this.messageType});

  Icon get icon {
    switch (messageType) {
      case MessageType.success:
        return const Icon(Icons.check_circle, color: Colors.green, size: 50.0);
      case MessageType.error:
        return const Icon(Icons.error, color: Colors.red, size: 50.0);
      case MessageType.warning:
        return const Icon(Icons.warning, color: Colors.orange, size: 50.0);
      case MessageType.info:
        return const Icon(Icons.info, color: Colors.blue, size: 50.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.bodyLarge;
    final messageStyle = Theme.of(context).textTheme.bodySmall;

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          width: 200.0,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title.isNotEmpty)
                PrettyText(
                  title,
                  style: titleStyle,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                ),
              if (message.isNotEmpty) const SizedBox(height: 20.0),
              if (message.isNotEmpty)
                PrettyText(
                  message,
                  style: messageStyle,
                  textAlign: TextAlign.center,
                  maxLines: 10,
                ),
              const SizedBox(height: 20.0),
              icon,
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
