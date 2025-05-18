import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../../global_types/index.dart';
import '../../../../global_widgets/index.dart';
import '../../../../strings/index.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final spacer = const SizedBox(height: 26.0);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              spacer,
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Locales.change(context, SupportedLocales.en);
                },
                child: PrettyText(
                  context.localeString(SettingsLanguageDialogStrings.english),
                ),
              ),
              spacer,
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Locales.change(context, SupportedLocales.es);
                },
                child: PrettyText(
                  context.localeString(SettingsLanguageDialogStrings.spanish),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
