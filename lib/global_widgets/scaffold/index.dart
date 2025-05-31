import 'package:flutter/material.dart';

import '../../global_helpers/index.dart';
import '../drawer/drawer.dart';
import '../header/index.dart';

class TbScaffold extends StatelessWidget {
  const TbScaffold({
    super.key,
    this.appBar,
    this.body,
    this.drawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.endDrawer,
    this.backgroundColor,
  });

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? endDrawer;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? Header(),
      body: body,
      // floatingActionButton: floatingActionButton,
      // floatingActionButtonLocation: floatingActionButtonLocation,
      // bottomNavigationBar: bottomNavigationBar,
      drawer: TbDrawer(),
      onDrawerChanged: (isOpen) {
        // Handle drawer state changes if needed
        ''.tbLogger('Drawer is ${isOpen ? 'open' : 'closed'}');
      },
      // endDrawer: endDrawer,
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
  // Scaffold widget with a custom app bar and bottom navigation bar
  
