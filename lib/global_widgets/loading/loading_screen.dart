import 'package:flutter/material.dart';
import 'package:tennisbookings/global_helpers/index.dart';
import 'package:tennisbookings/global_widgets/index.dart';
import 'package:tennisbookings/screens/home_screen.dart';
import 'package:tennisbookings/theme/colors.dart';

import '../header/index.dart';

class LoadingScreen extends StatelessWidget {
  final String message;
  const LoadingScreen({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  final String message;
  const NotFoundScreen({super.key, this.message = 'Not found'});

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final fontSize = getFontSize(mobile);
    return Scaffold(
      appBar: Header(),
      body: Center(
        child: Column(
          spacing: 10,
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
      ),
    );
  }
}
