import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../config/config.dart';
import '../../global_types/index.dart';
import 'index.dart';

class EventNotifier extends StateNotifier<EventStatus> {
  EventNotifier() : super(const EventStatus.empty());

  void showLoading({String? title, String? message}) {
    state = state.copyWith(title: title ?? '', message: message ?? '', isLoading: true, eventType: EventType.loadingBox);
  }

  void hideLoading() {
    state = state.copyWith(title: '', message: '', isLoading: false);
  }

  void showMessage({
    String title = '',
    String message = '',
    required MessageType messageType,
    Duration duration = Config.defaultNotifierDuration,
  }) {
    state = state.copyWith(title: title, message: message, eventType: EventType.message, messageType: messageType);
    Future.delayed(duration, () {
      state = state.copyWith(title: '', message: '', eventType: EventType.none);
    });
  }
}
