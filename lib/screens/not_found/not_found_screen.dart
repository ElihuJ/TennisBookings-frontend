import 'package:flutter/material.dart';

import '../../global_widgets/index.dart';

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
              'Page Not Found',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: PrettyText('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
