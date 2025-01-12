import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/state/index.dart';

import 'index.dart';

final cloudFunctionsProvider = StateNotifierProvider<CloudFunctionsNotifier, CloudFunctions>((ref) {
  final fbAuth = ref.watch(firebaseAuthProvider);
  final uid = fbAuth.uid;
  if (uid != null) {
    return CloudFunctionsNotifier()..loadUid(uid: uid);
  }
  return CloudFunctionsNotifier();
});
