import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cart/circular_cart_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/top_wave_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/support/circular_support_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

/// A screen's wave header and white body. The wave stays put while the body
/// scrolls (BUG-009); it used to flatten into a straight edge.
class AppWavedView extends StatelessWidget {
  const AppWavedView({
    super.key,
    required this.body,
    required this.appBarTitle,
    this.loadAppBarTitle = false,
    this.hasCartIcon = false,
    this.hasSupportIcon = false,
    this.onSupportTap,
    this.canPop,
    this.bodyPadding,
    this.onCartTap,
    this.scrollController,
    this.leading,
    this.actions,
  });
  final String appBarTitle;
  final bool loadAppBarTitle;
  final bool hasCartIcon;
  final bool hasSupportIcon;
  final VoidCallback? onSupportTap;
  final VoidCallback? onCartTap;
  final bool? canPop;
  final Widget body;
  final Widget? leading;
  final List<Widget>? actions;
  final EdgeInsets? bodyPadding;

  /// Set when the body scrolls: its top spacing then belongs to the scroll
  /// view (so it scrolls up with the content) and is dropped here.
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Size screenSize = MediaQuery.sizeOf(context);
    final EdgeInsets basePadding =
        bodyPadding ??
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 57,
        ).copyWith(bottom: 20);

    // The outer SafeArea uses bottom:false so the wave gradient bleeds to the
    // screen edge — which left the last list item / docked button riding under
    // the home-indicator/gesture bar on the pushed screens (My Address, Discount
    // Codes, Wallet, cards). Reserve the device bottom inset in the white body
    // padding instead, so content clears the bar without capping the gradient.
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final EdgeInsets insetBodyPadding = basePadding.copyWith(
      bottom: basePadding.bottom + bottomInset,
    );

    final EdgeInsets effectiveBodyPadding = scrollController != null
        ? insetBodyPadding.copyWith(top: 0)
        : insetBodyPadding;

    const TopWaveClipper waveClipper = TopWaveClipper();

    final Widget leadingWidget =
        leading ??
        (canPop ?? context.canPop()
            ? InkWell(
                onTap: () => Navigator.maybePop(context),
                child: ReverseWidget(
                  applyReverse: context.isRTL,
                  child: CircleAvatar(
                    backgroundColor: colors.white,
                    radius: screenSize.width * 0.05,
                    child: Center(
                      child: Assets.media.images.svg.appBackArrow.svg(
                        fit: BoxFit.contain,
                        width: screenSize.width * 0.05,
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink());

    final Widget trailing =
        hasCartIcon || hasSupportIcon || (actions?.isNotEmpty ?? false)
        ? Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              ...?actions,
              if (hasSupportIcon)
                CircularSupportIcon(
                  size: screenSize.width * 0.05,
                  onTap:
                      onSupportTap ??
                      () {
                        context.pushNamed(AppRoutes.supportScreen);
                      },
                ),
              if (hasCartIcon)
                CircularCartButton(
                  size: screenSize.width * 0.05,
                  onTap:
                      onCartTap ??
                      () {
                        context.pushNamed(AppRoutes.cartScreen);
                      },
                ),
            ],
          )
        : const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 0.5,
          colors: [
            colors.onSecondaryFixed.withValues(alpha: 0.7),
            colors.onSecondaryFixed,
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          spacing: 12,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      Visibility(
                        visible: false,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: trailing,
                      ),
                      leadingWidget,
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: loadAppBarTitle
                          ? Center(
                              child: AppShimmer(
                                child: Container(
                                  width: 120,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              appBarTitle,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                              style: AppTextStyles.style24SemiBold.copyWith(
                                color: colors.black,
                                fontSize: screenSize.width * 0.05,
                              ),
                            ),
                    ),
                  ),
                  Stack(
                    alignment: AlignmentDirectional.centerEnd,
                    children: [
                      Visibility(
                        visible: false,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: leadingWidget,
                      ),
                      trailing,
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipPath(
                clipper: waveClipper,
                child: Container(
                  color: colors.neutral500.withValues(alpha: 0.05),
                  padding: const EdgeInsets.only(top: 5),
                  child: ClipPath(
                    clipper: waveClipper,
                    child: Container(
                      padding: effectiveBodyPadding,
                      decoration: BoxDecoration(
                        color: colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),
                      child: body,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
