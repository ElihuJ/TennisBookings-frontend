import 'package:flutter/material.dart';

import '../../global_helpers/index.dart';
import '../../screens/home_screen.dart';
import '../../theme/colors.dart';
import '../containers/bordered_box.dart';
import '../index.dart';

class LoadingScreen extends StatelessWidget {
  final String message;
  const LoadingScreen({super.key, this.message = 'Loading...', this.noScaffold = false});

  final bool noScaffold;

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);

    final height = mobileView ? MediaQuery.of(context).size.height / 3 : MediaQuery.of(context).size.height / 2;

    final width = mobileView ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 4;

    final body = Center(
      child: BorderedBox(
        backgroundColor: AppColors.white,
        height: height,
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: 20),
            PrettyText(message),
          ],
        ),
      ),
    );

    if (noScaffold) {
      return body;
    }

    return TbScaffold(
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

    return TbScaffold(
      body: body,
    );
  }
}
