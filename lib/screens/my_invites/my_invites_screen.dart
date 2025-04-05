import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../global_widgets/header/index.dart';
import '../../global_widgets/index.dart';
import '../../state/index.dart';

class MyInvitesScreen extends HookConsumerWidget {
  const MyInvitesScreen({super.key});

  static const route = 'MyInvites';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isLoggedIn = user.uid.isNotEmpty;

    if (!isLoggedIn) {
      return const NotFoundScreen();
    }
    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          appBar: Header(),
          body: Center(
            child: Container(
              margin: const EdgeInsets.only(top: 100.0),
              height: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const PrettyText(
                      'My Invites',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const PrettyText(
                      'You have no invites',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
