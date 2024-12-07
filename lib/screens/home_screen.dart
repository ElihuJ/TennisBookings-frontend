import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../strings/settings/index.dart';
import '../types/index.dart';
import '../widgets/eventful/eventful.dart';
import '../widgets/header/header.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  static const route = 'Home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          appBar: Header(),
          body: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
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
      ),
    );
  }
}
