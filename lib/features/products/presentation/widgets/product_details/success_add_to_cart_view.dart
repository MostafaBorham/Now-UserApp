import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

class SuccessAddToCartView extends StatefulWidget {
  const SuccessAddToCartView({
    super.key,
    this.productName = 'MacBook Air 3',
    this.productImageUrl =
        'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
    this.title,
    this.viewCartLabel,
    this.continueShoppingLabel,
    this.onViewCart,
    this.onContinueShopping,
  });

  final String productName;
  final String productImageUrl;
  final String? title;
  final String? viewCartLabel;
  final String? continueShoppingLabel;
  final GestureTapCallback? onViewCart;
  final GestureTapCallback? onContinueShopping;

  @override
  State<SuccessAddToCartView> createState() => _SuccessAddToCartViewState();
}

class _SuccessAddToCartViewState extends State<SuccessAddToCartView>
    with SingleTickerProviderStateMixin {


  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: Curves.easeOutBack),
      ),
      weight: 30,
    ),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
      RepaintBoundary(
      child: ScaleTransition(
      scale: _scale,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [

          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colors.primary500Main.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),

          Container(
            width: 96,
            height: 96,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary500Main.withValues(alpha: 0.35),
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

          PositionedDirectional(
            start: 4,
            bottom: 4,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: colors.primary500Main,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 14,
                color: colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
    ),
          ScaleTransition(
            scale: _scale,
            child: Text(
              widget.productName,
              textAlign: TextAlign.center,
              style: AppTextStyles.style14Medium.copyWith(
                color: colors.black,
              ),
            ),
          ),
          15.hSpace,
          Text(
            widget.title ?? LangKeys.inTheShoppingCartKey.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.style20Bold.copyWith(
              color: colors.black,
            ),
          ),
          8.hSpace,
          SizedBox(
            height: 50,
            child: Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: PrimaryAppButton(
                    title: widget.viewCartLabel ?? LangKeys.viewCartKey.tr(),
                    onTap: widget.onViewCart,
                  ),
                ),
                Expanded(
                  child: UnPrimaryAppButton(
                    title: widget.continueShoppingLabel ??
                        LangKeys.continueShoppingKey.tr(),
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
}
