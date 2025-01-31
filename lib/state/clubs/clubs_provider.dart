import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/cloud_functions/index.dart';

import 'index.dart';

final clubsProvider = StateNotifierProvider<ClubsNotifier, List<Club>>((ref) {
  final cloudFunctionsNotifier = ref.watch(cloudFunctionsProvider.notifier);
  return ClubsNotifier(cloudFunctionsNotifier);
});
