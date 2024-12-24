import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../firebase/index.dart';
import 'index.dart';

final clubsProvider = StateNotifierProvider<ClubsNotifier, List<Club>>((ref) {
  final fbAuth = ref.watch(firebaseAuthProvider);
  final currentUser = fbAuth.firebaseInstance.currentUser;

  final uid = currentUser?.uid;
  final isVerified = currentUser?.emailVerified ?? false;

  if (uid != null && isVerified) {
    return ClubsNotifier()..loadClubs();
  }
  return ClubsNotifier();
});
