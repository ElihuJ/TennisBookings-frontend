import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'index.dart';

final eventsProvider = StateNotifierProvider<EventStatusNotifier, EventStatus>((ref) {
  return EventStatusNotifier();
});
