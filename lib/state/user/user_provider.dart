import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../cloud_functions/index.dart';
import '../firebase/index.dart';
import 'index.dart';

final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  final fbAuth = ref.watch(firebaseAuthProvider);
  final currentUser = fbAuth.firebaseInstance.currentUser;
  final cloudFunctionsNotifier = ref.watch(cloudFunctionsProvider.notifier);

  final uid = currentUser?.uid;
  final isVerified = currentUser?.emailVerified ?? false;

  if (uid != null && isVerified) {
    return UserNotifier(cloudFunctionsNotifier: cloudFunctionsNotifier)..loadUser(uid: uid);
  }
  return UserNotifier(cloudFunctionsNotifier: cloudFunctionsNotifier);
});
