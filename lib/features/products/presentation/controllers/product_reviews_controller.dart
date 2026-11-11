import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nowdelivery_user_app/core/enums/reviews_sort_option.dart';

class ProductReviewsController with WidgetsBindingObserver {
  ProductReviewsController({
    required TickerProvider vsync,
    required FlutterView view,
  }) : _view = view,
       _collapseAnimation = AnimationController(
         vsync: vsync,
         duration: const Duration(milliseconds: 300),
       ),
       _keyboardAnimation = AnimationController(
         vsync: vsync,
         duration: const Duration(milliseconds: 200),
       ) {
    _collapseProgress = CurvedAnimation(
      parent: _collapseAnimation,
      curve: Curves.easeInOut,
    );
    _keyboardProgress = CurvedAnimation(
      parent: _keyboardAnimation,
      curve: Curves.easeOut,
    );
    visibility = ReverseAnimation(_collapseProgress);
    summaryVisibility = AnimationMin<double>(
      visibility,
      ReverseAnimation(_keyboardProgress),
    );
    WidgetsBinding.instance.addObserver(this);
  }

  static const Duration _restoreDelay = Duration(seconds: 1);

  final FlutterView _view;
  final AnimationController _collapseAnimation;
  final AnimationController _keyboardAnimation;
  late final CurvedAnimation _collapseProgress;
  late final CurvedAnimation _keyboardProgress;
  late final Animation<double> visibility;
  late final Animation<double> summaryVisibility;
  final TextEditingController commentController = TextEditingController();
  final ValueNotifier<int> rating = ValueNotifier<int>(0);
  ReviewsSortOption? sortOption;
  Timer? _restoreTimer;
  bool _isKeyboardOpen = false;

  void selectRating(int value) => rating.value = value;

  void applySortOption(ReviewsSortOption? option) => sortOption = option;

  bool onUserScroll(UserScrollNotification notification) {
    if (notification.depth != 0 || _isKeyboardOpen) return false;
    _restoreTimer?.cancel();
    if (notification.direction == ScrollDirection.idle) {
      _restoreTimer = Timer(_restoreDelay, _collapseAnimation.reverse);
    } else {
      _collapseAnimation.forward();
    }
    return false;
  }

  @override
  void didChangeMetrics() {
    final bool isKeyboardOpen = _view.viewInsets.bottom > 0;
    if (isKeyboardOpen == _isKeyboardOpen) return;
    _isKeyboardOpen = isKeyboardOpen;
    if (isKeyboardOpen) {
      _restoreTimer?.cancel();
      _collapseAnimation.reverse();
      _keyboardAnimation.forward();
    } else {
      _keyboardAnimation.reverse();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _restoreTimer?.cancel();
    _collapseProgress.dispose();
    _keyboardProgress.dispose();
    _collapseAnimation.dispose();
    _keyboardAnimation.dispose();
    commentController.dispose();
    rating.dispose();
  }
}
