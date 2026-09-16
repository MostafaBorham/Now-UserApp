import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

/// Opens the confirmation sheet for a product that just landed in the cart.
///
/// Every "add to cart" action answers this way, so the sheet is configured in
/// one place. [onContinueShopping] runs after the sheet closes; the default —
/// staying put — suits any screen the shopper can keep browsing from, so only
/// screens that need to step back (product details) pass their own.
Future<void> showSuccessAddToCartSheet(
  BuildContext context, {
  required String productName,
  required String productImageUrl,
  VoidCallback? onContinueShopping,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext sheetContext) => SuccessAddToCartView(
      productName: productName,
      productImageUrl: productImageUrl,
      onViewCart: () {
        Navigator.of(sheetContext).pop();
        context.pushNamed(AppRoutes.cartScreen);
      },
      onContinueShopping: () {
        Navigator.of(sheetContext).pop();
        onContinueShopping?.call();
      },
    ),
  );
}

/// Bottom sheet confirming that a product just landed in the cart.
class SuccessAddToCartView extends StatefulWidget {
  const SuccessAddToCartView({
    super.key,
    required this.productName,
    required this.productImageUrl,
    this.onViewCart,
    this.onContinueShopping,
  });

  final String productName;
  final String productImageUrl;
  final GestureTapCallback? onViewCart;
  final GestureTapCallback? onContinueShopping;

  @override
  State<SuccessAddToCartView> createState() => _SuccessAddToCartViewState();
}

class _SuccessAddToCartViewState extends State<SuccessAddToCartView>
    with SingleTickerProviderStateMixin {
  // The whole entrance is one 1.2s pass played once. Each element below owns a
  // slice of that timeline, matching the Figma motion spec: the product circle
  // pops in first, its green glow fades up behind it, then the check badge and
  // the product name arrive.
  static const Cubic _overshoot = Cubic(0.34, 1.2, 0.64, 1);
  static const Cubic _easeOut = Cubic(0.16, 1, 0.3, 1);
  static const Cubic _textEase = Cubic(0.22, 1, 0.36, 1);

  static const Interval _circlePop = Interval(0, 0.375, curve: _overshoot);
  static const Interval _circleFade = Interval(0, 0.125, curve: _easeOut);
  static const Interval _glowFade = Interval(0.4167, 0.6667, curve: _easeOut);
  static const Interval _badgePop = Interval(0.2917, 0.5, curve: _overshoot);
  static const Interval _badgeFade = Interval(0.2917, 0.4167);
  static const Interval _nameFade = Interval(0, 0.3333, curve: _textEase);
  static const Interval _nameRise = Interval(0, 0.4167, curve: _textEase);
  static const Interval _namePop = Interval(0, 0.5, curve: Curves.easeOutBack);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => _buildProductBadge(colors),
                ),
                8.hSpace,
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final double t = _controller.value;
                    return Opacity(
                      opacity: _nameFade.transform(t),
                      child: Transform.translate(
                        offset: Offset(0, 12 * (1 - _nameRise.transform(t))),
                        child: Transform.scale(
                          scale: 0.5 + 0.5 * _namePop.transform(t),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    widget.productName,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.style14Medium.copyWith(
                      color: colors.black,
                    ),
                  ),
                ),
                16.hSpace,
                Text(
                  LangKeys.inTheShoppingCartKey.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.style20Bold.copyWith(color: colors.black),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: colors.neutral200),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  child: PrimaryAppButton(
                    title: LangKeys.viewCartKey.tr(),
                    titleStyle: AppTextStyles.style16Medium,
                    onTap: widget.onViewCart,
                  ),
                ),
                Expanded(
                  child: UnPrimaryAppButton(
                    title: LangKeys.continueShoppingKey.tr(),
                    titleStyle: AppTextStyles.style16Medium,
                    onTap: widget.onContinueShopping,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductBadge(AppColorScheme colors) {
    final double t = _controller.value;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Soft halo behind the product badge; it is already in place when the
        // sheet opens, so the circle can pop into it.
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: colors.primary500Main.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
        ),
        // Product image circle with the green success glow.
        Opacity(
          opacity: _circleFade.transform(t),
          child: Transform.scale(
            scale: _circlePop.transform(t),
            child: Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.primary500Main.withValues(
                      alpha: 0.35 * _glowFade.transform(t),
                    ),
                    offset: const Offset(0, 10),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: ClipOval(
                child: AppCachedNetworkImage(
                  imageUrl: widget.productImageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        // Success check badge.
        // ponytail: the badge pops in whole; Figma also trims the tick's path
        // on (400→750ms), which needs a CustomPainter — add it if the detail
        // turns out to be missed.
        PositionedDirectional(
          start: 0,
          bottom: 17,
          child: Opacity(
            opacity: _badgeFade.transform(t),
            child: Transform.scale(
              scale: _badgePop.transform(t),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors.primary500Main,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 11, color: colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
