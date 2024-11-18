import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'config/config.dart';
import 'config/screen_size.dart';
import 'routes/main_routes.dart';

class Entry extends StatelessWidget {
  const Entry({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ProviderScope(
      child: LocaleBuilder(
        builder: (locale) => MaterialApp(
          locale: locale,
          supportedLocales: Locales.supportedLocales,
          localizationsDelegates: Locales.delegates,
          debugShowCheckedModeBanner: false,
          title: Config.appName,
          onGenerateRoute: generateLoginRoutes,
          theme: Config.theme,
        ),
      ),
    );
  }
}
