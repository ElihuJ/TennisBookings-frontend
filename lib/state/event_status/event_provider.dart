import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'index.dart';

final eventProvider = StateNotifierProvider<EventNotifier, EventStatus>((ref) {
  return EventNotifier();
});
