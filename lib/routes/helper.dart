// // * Purpose of this is to overwrite animation time on transition to make it instant
import 'package:flutter/material.dart';

class MyEsRoute<T> extends MaterialPageRoute<T> {
  MyEsRoute({required super.builder, required RouteSettings super.settings});

  @override
  Duration get transitionDuration => const Duration(milliseconds: 1);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
