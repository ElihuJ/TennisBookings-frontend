import 'package:flutter/material.dart';

import '../drawer/drawer.dart';
import '../header/index.dart';
import 'package:universal_html/html.dart' as html;

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
      body: RefreshIndicator(
        child: body ?? const SizedBox.shrink(),
        onRefresh: () async => {html.window.location.reload()},
      ),
      drawer: TbDrawer(),
      backgroundColor: backgroundColor ?? Colors.transparent,
    );
  }
}
