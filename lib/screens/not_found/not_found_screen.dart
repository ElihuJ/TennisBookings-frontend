import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../global_widgets/index.dart';
import '../../strings/index.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  static const route = 'NotFound';

  @override
  Widget build(BuildContext context) {
    return TbScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 100.0,
              color: Colors.red,
            ),
            SizedBox(height: 20.0),
            PrettyText(
              '404',
              style: TextStyle(fontSize: 50.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            PrettyText(
              context.localeString(GeneralStrings.notFoundTitle),
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: PrettyText(context.localeString(GeneralStrings.goBack)),
            ),
          ],
        ),
      ),
    );
  }
}
