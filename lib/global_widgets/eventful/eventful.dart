import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:universal_html/html.dart' as html;

import '../../state/config/index.dart';
import '../../state/event_status/event_provider.dart';
import '../../state/event_status/event_state.dart';
import '../containers/loading_box.dart';
import '../containers/message.dart';

class EventfulWidget extends HookConsumerWidget {
  const EventfulWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventStatus = ref.watch(eventProvider);
    final eventStatusNotifier = ref.read(eventProvider.notifier);
    final configNotifier = ref.read(firebaseConfigProvider.notifier);
    ref.watch(firebaseConfigProvider);

    final requireUpdate = configNotifier.requireUpdate(eventStatusNotifier: eventStatusNotifier);

    return Stack(
      children: [
        child,
        if (eventStatus.eventType == EventType.loadingBox && eventStatus.isLoading == true)
          LoadingBox(message: eventStatus.message, title: eventStatus.title ?? ''),
        if (eventStatus.eventType == EventType.message)
          Message(
            message: eventStatus.message,
            title: eventStatus.title ?? '',
            messageType: eventStatus.messageType!,
          ),
        if (requireUpdate)
          MessageWithAction(
              message: 'A new version of the app is available. Please update to continue.',
              title: 'Update Required',
              buttonText: 'Update',
              onPressed: () {
                html.window.location.reload();
              }),
      ],
    );
  }
}
