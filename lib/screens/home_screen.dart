import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../assets/index.dart';
import '../global_widgets/eventful/eventful.dart';
import '../global_widgets/header/header.dart';
import '../theme/index.dart';
import 'login/widgets/containers.dart';
// import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  static const route = 'Home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final smallScreen = screenWidth < 600;

    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          appBar: Header(),
          body: ContainerWithBackground(
            imagePath: homeBackgroundPng,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: 20),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.black.withValues(alpha: 0.2),
                    border: Border.all(color: AppColors.almostWhite, width: 2),
                    backgroundBlendMode: BlendMode.multiply,
                  ),
                  child: Container(
                    margin: EdgeInsets.all(40),
                    child: Text(
                      'GET A COURT \nFIND A PARTNER\nPLAY',
                      style: TextStyle(
                        fontSize: smallScreen ? 20 : 60,
                        color: AppColors.almostWhite,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
