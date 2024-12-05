import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'index.dart';

final firebaseAuthProvider = StateNotifierProvider<FirebaseAuthNotifier, FirebaseAuth>((ref) {
  return FirebaseAuthNotifier();
});
