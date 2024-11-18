// ignore: depend_on_referenced_packages
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import '../../config/config.dart';
import '../../types/index.dart';

Flushbar? showToast({required BuildContext context, required String message, required MessageType messageType, String? title, Function? postAction}) {
  final color = getColor(messageType);
  final icon = getIcon(messageType);

  if (context.mounted) {
    return Flushbar(
      title: title,
      message: message,
      icon: icon,
      duration: Config.mediumNotifierDuration,
      backgroundGradient: color,
      onTap: (flushbar) => flushbar.dismiss(),
    )..show(context).then((_) {
        if (postAction != null) {
          postAction();
        }
      });
  }
  return null;
}

LinearGradient getColor(MessageType messageType) {
  switch (messageType) {
    case MessageType.success:
      return LinearGradient(
        colors: [Colors.green[600]!, Colors.green[400]!],
      );
    case MessageType.error:
      return LinearGradient(
        colors: [Colors.red[600]!, Colors.red[400]!],
      );
    case MessageType.warning:
      return LinearGradient(
        colors: [Colors.orange[600]!, Colors.orange[400]!],
      );
    case MessageType.info:
      return LinearGradient(
        colors: [Colors.blue[600]!, Colors.blue[400]!],
      );
  }
}

Icon getIcon(MessageType messageType) {
  const iconSize = 28.0;
  const iconColor = Colors.white;
  switch (messageType) {
    case MessageType.success:
      return const Icon(
        Icons.check,
        size: iconSize,
        color: iconColor,
      );
    case MessageType.error:
      return const Icon(
        Icons.error,
        size: iconSize,
        color: iconColor,
      );
    case MessageType.warning:
      return const Icon(
        Icons.warning,
        size: iconSize,
        color: iconColor,
      );
    case MessageType.info:
      return const Icon(
        Icons.info,
        size: iconSize,
        color: iconColor,
      );
  }
}
