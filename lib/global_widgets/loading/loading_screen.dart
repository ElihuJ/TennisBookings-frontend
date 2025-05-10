import 'package:flutter/material.dart';
import 'package:tennisbookings/global_widgets/containers/bordered_box.dart';

import '../../global_helpers/index.dart';
import '../../screens/home_screen.dart';
import '../../theme/colors.dart';
import '../header/index.dart';
import '../index.dart';

class LoadingScreen extends StatelessWidget {
  final String message;
  const LoadingScreen({super.key, this.message = 'Loading...', this.noScaffold = false});

  final bool noScaffold;

  @override
  Widget build(BuildContext context) {
    final body = BorderedBox(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(message),
        ],
      ),
    );

    if (noScaffold) {
      return body;
    }

    return Scaffold(
      appBar: Header(),
      body: body,
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  final String message;
  final bool noScaffold;

  const NotFoundScreen({super.key, this.message = 'Not found', this.noScaffold = false});

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final fontSize = getFontSize(mobile);

    final body = BorderedBox(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.red,
            size: 80,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: PrettyText(
              message,
              maxLines: 4,
              style: TextStyle(
                fontSize: fontSize + 4,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          TbTextButton(
            onPressed: () => Navigator.of(context).pushNamed(HomeScreen.route),
            text: 'Go Back',
            color: AppColors.red,
          ),
        ],
      ),
    );

    if (noScaffold) {
      return body;
    }

    return Scaffold(
      appBar: Header(),
      body: body,
    );
  }
}
