import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// The app's screen-change motion.
///
/// Android: [AppSlidePageTransitionsBuilder]. Flutter's default there cross-
/// fades both full pages on every frame, which is costly to draw and read as
/// an abrupt cut on mid-range phones. iOS keeps its native slide and
/// swipe-back gesture.
const PageTransitionsTheme appPageTransitionsTheme = PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: AppSlidePageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
);

/// The new screen slides in from the reading edge (the right in English, the
/// left in Arabic) while the one beneath drifts a little the other way, and
/// back out on pop.
///
/// Only translation is animated: no opacity, no shadow, so each frame just
/// moves two already-drawn pages. Decelerating on the way in and accelerating
/// on the way out, like the platform navigation it stands in for.
class AppSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const AppSlidePageTransitionsBuilder();

  static const Duration duration = Duration(milliseconds: 320);

  /// How far the page beneath moves while it is covered, as a fraction of the
  /// screen width.
  static const double parallax = 0.25;

  static const Curve _curveIn = Curves.easeOutCubic;
  static const Curve _curveOut = Curves.easeInCubic;

  @override
  Duration get transitionDuration => duration;

  @override
  Duration get reverseTransitionDuration => duration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final TextDirection direction = Directionality.of(context);

    final Animation<Offset> enter = CurvedAnimation(
      parent: animation,
      curve: _curveIn,
      reverseCurve: _curveOut,
    ).drive(Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero));

    final Animation<Offset> coveredBy = CurvedAnimation(
      parent: secondaryAnimation,
      curve: _curveIn,
      reverseCurve: _curveOut,
    ).drive(Tween<Offset>(begin: Offset.zero, end: const Offset(-parallax, 0)));

    return SlideTransition(
      position: coveredBy,
      textDirection: direction,
      transformHitTests: false,
      child: SlideTransition(
        position: enter,
        textDirection: direction,
        child: child,
      ),
    );
  }
}
