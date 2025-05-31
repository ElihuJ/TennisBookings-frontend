import 'package:flutter/material.dart';

import '../../text/index.dart';

void showPrivateWallModal({required BuildContext context, String? message}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const PrettyText('Private booking'),
        content: PrettyText(message ?? 'This booking is private and only visible to the owner.'),
        actions: <Widget>[
          TextButton(
            child: const PrettyText('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
