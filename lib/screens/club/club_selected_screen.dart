import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../global_widgets/header/index.dart';
import '../../state/clubs/index.dart';

class ClubSelectedScreen extends HookConsumerWidget {
  const ClubSelectedScreen({super.key, required this.clubSelected});

  final Club clubSelected;
  static const String route = 'ClubSchedule';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: Header(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(clubSelected.name)],
        ),
      ),
    );
  }
}
