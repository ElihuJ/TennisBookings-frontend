import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../state/event_status/event_provider.dart';
import '../../state/event_status/event_state.dart';
import '../containers/loading_box.dart';
import '../containers/message.dart';

class EventfulWidget extends HookConsumerWidget {
  const EventfulWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventStatus = ref.watch(eventStatusProvider);

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
      ],
    );
  }
}
