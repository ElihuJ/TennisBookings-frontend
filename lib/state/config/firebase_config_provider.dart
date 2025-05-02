import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'index.dart';

final firebaseConfigProvider = StateNotifierProvider<FirebaseConfigNotifier, FirebaseConfig>((ref) {
  return FirebaseConfigNotifier()..loadConfig();
});
