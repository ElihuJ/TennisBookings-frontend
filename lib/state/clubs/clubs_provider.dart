import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'index.dart';

final clubsProvider = StateNotifierProvider<ClubsNotifier, List<Club>>((ref) {
  return ClubsNotifier();
});
