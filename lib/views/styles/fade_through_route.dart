import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Example:
///
/// fadeThrough((context, animation, secondaryAnimation) => const HomePage())
Route<T> fadeThrough<T>(RoutePageBuilder page, [double duration = 0.3]) {
  return PageRouteBuilder<T>(
    transitionDuration: Duration(milliseconds: (duration * 1000).round()),
    pageBuilder: (context, animation, secondaryAnimation) => page(
      context,
      animation,
      secondaryAnimation,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child);
    },
  );
}
