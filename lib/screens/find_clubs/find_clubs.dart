import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../assets/index.dart';
import '../../global_widgets/eventful/eventful.dart';
import '../../global_widgets/header/index.dart';
import '../../global_widgets/index.dart';
import '../../state/index.dart';
import '../login/widgets/containers.dart';

class FindClubsScreen extends HookConsumerWidget {
  const FindClubsScreen({super.key});
  static const route = 'FindClubs';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseAuthNotifier = ref.read(firebaseAuthProvider.notifier);
    final userNotifier = ref.read(userProvider.notifier);
    final eventNotifier = ref.read(eventStatusProvider.notifier);

    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: Scaffold(
            appBar: Header(),
            body: ContainerWithBackground(
              imagePath: homeBackgroundPng,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'FIND A CLUB', // TODO : TRANSLATE
                    style: TextStyle(
                      fontSize: 60,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Find a club near you', // TODO : TRANSLATE
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            )),
      ),
    );
  }
}
