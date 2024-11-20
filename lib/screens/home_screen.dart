import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/helpers/index.dart';
import 'package:tennisbookings/widgets/header/header.dart';

import '../state/event_status/index.dart';
import '../widgets/eventful/eventful.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  static const route = 'Home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
    final isLoggedIn = currentUser != null && currentUser.emailVerified;
    final eventNotifier = ref.watch(eventStatusProvider.notifier);
    final event = ref.watch(eventStatusProvider);

    event.tbLogger('Event Status');

    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          appBar: Header(),
          body: Column(
            children: [
              Center(
                child: Text('Home Screen $isLoggedIn'),
              ),
              ElevatedButton(
                onPressed: () async {
                  'HomeScreen'.tbLogger('Button pressed');
                  eventNotifier.showLoading(
                      title: 'Loading', message: 'Please wait');
                  await wait(2000);
                  eventNotifier.hideLoading();
                },
                child: const Text('Press me'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
