import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_name.dart';

class ProductDetailsController {
  ProductDetailsController({
    required TickerProvider vsync,
    this.expansionScrollExtent = 0,
  }) : _titleAnimation = AnimationController(
         vsync: vsync,
         duration: const Duration(milliseconds: 300),
       ) {
    titleProgress = CurvedAnimation(
      parent: _titleAnimation,
      curve: Curves.easeInOut,
    );
    scrollController.addListener(syncPinnedProductName);
  }

  static const double _productNameUnpinTolerance = 8;
  double expansionScrollExtent;

  final AnimationController _titleAnimation;
  late final CurvedAnimation titleProgress;
  final ScrollController scrollController = ScrollController();
  final GlobalKey productNameKey = GlobalKey();
  final ValueNotifier<bool> isProductNamePinned = ValueNotifier<bool>(false);
  final ValueNotifier<double> productNameShift = ValueNotifier<double>(0);
  final ValueNotifier<double> pinProgress = ValueNotifier<double>(0);

  bool onScrollMetricsChanged(ScrollMetricsNotification notification) {
    if (notification.depth == 0) syncPinnedProductName();
    return false;
  }

  void syncPinnedProductName() {
    final BuildContext? productNameContext = productNameKey.currentContext;
    final RenderObject? productName = productNameContext?.findRenderObject();
    if (productNameContext == null ||
        productName is! RenderBox ||
        !productName.attached ||
        !productName.hasSize ||
        !scrollController.hasClients) {
      productNameShift.value = 0;
      pinProgress.value = 0;
      _setProductNamePinned(false);
      return;
    }
    final double offset = scrollController.offset;
    if (offset <= expansionScrollExtent) {
      productNameShift.value = 0;
      pinProgress.value = 0;
      _setProductNamePinned(false);
      return;
    }
    final double pinOffset =
        RenderAbstractViewport.of(
          productName,
        ).getOffsetToReveal(productName, 0).offset +
        MediaQuery.textScalerOf(
              productNameContext,
            ).scale(ProductDetailsName.fontSize) *
            ProductDetailsName.lineHeight /
            2 -
        MediaQuery.paddingOf(productNameContext).top -
        kToolbarHeight / 2;
    final double shift = pinOffset - offset;
    productNameShift.value = math.max(0.0, shift);
    final double contentOffset = offset - expansionScrollExtent;
    final double contentPinOffset = pinOffset - expansionScrollExtent;
    pinProgress.value = contentPinOffset <= 0
        ? 1
        : clampDouble(contentOffset / contentPinOffset, 0, 1);
    final double pinTolerance = isProductNamePinned.value
        ? _productNameUnpinTolerance
        : 0;
    _setProductNamePinned(shift <= pinTolerance);
  }

  void _setProductNamePinned(bool isPinned) {
    if (isProductNamePinned.value == isPinned) return;
    isProductNamePinned.value = isPinned;
    if (isPinned) {
      _titleAnimation.forward();
    } else {
      _titleAnimation.reverse();
    }
  }

  void dispose() {
    scrollController.dispose();
    titleProgress.dispose();
    _titleAnimation.dispose();
    isProductNamePinned.dispose();
    productNameShift.dispose();
    pinProgress.dispose();
  }
}
