import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/helpers/index.dart';
import 'package:tennisbookings/strings/settings/index.dart';
import 'package:tennisbookings/widgets/header/header.dart';

import '../state/event_status/index.dart';
import '../types/index.dart';
import '../widgets/eventful/eventful.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  static const route = 'Home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
    final isLoggedIn = currentUser != null && currentUser.emailVerified;
    final eventNotifier = ref.watch(eventStatusProvider.notifier);

    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          appBar: Header(),
          body: Column(
            children: [
              Spacer(),
              Center(
                child: Text('Logged in: $isLoggedIn'),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () async {
                  eventNotifier.showMessage(
                    message: 'Data loaded successfully',
                    messageType: MessageType.success,
                  );
                },
                child: const Text('Load button'),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () => Locales.change(context, SupportedLocales.en),
                child: Text(
                  context.localeString(SettingsLanguageDialogStrings.english),
                ),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () => Locales.change(context, SupportedLocales.es),
                child: Text(
                  context.localeString(SettingsLanguageDialogStrings.spanish),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
