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
    this.titleBadge,
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
    this.waveGap = 12,
    this.flattenOnScroll = false,
  });
  final String appBarTitle;

  /// Shown after the title, centred with it (e.g. a store's status pill).
  final Widget? titleBadge;
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

  /// Space between the app bar row and the top of the wave.
  final double waveGap;

  /// Set when the body scrolls: its top spacing then belongs to the scroll
  /// view (so it scrolls up with the content) and is dropped here.
  final ScrollController? scrollController;

  /// Trial (category details only, from dev-borham): the wave eases flat
  /// while a vertical list in [body] is scrolled off its top, and back at the
  /// top. Off everywhere else, where the wave stays put (BUG-009).
  final bool flattenOnScroll;

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

    final Widget title = Text(
      appBarTitle,
      textAlign: TextAlign.center,
      overflow: TextOverflow.visible,
      style: AppTextStyles.style24SemiBold.copyWith(
        color: colors.black,
        fontSize: screenSize.width * 0.05,
      ),
    );

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
          spacing: waveGap,
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
                          : titleBadge == null
                          ? title
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 8,
                              children: [
                                Flexible(child: title),
                                titleBadge!,
                              ],
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
              child: _WaveBody(
                flattenOnScroll: flattenOnScroll,
                padding: effectiveBodyPadding,
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The white body under the wave; owns the flattening animation.
class _WaveBody extends StatefulWidget {
  const _WaveBody({
    required this.flattenOnScroll,
    required this.padding,
    required this.child,
  });

  final bool flattenOnScroll;
  final EdgeInsets padding;
  final Widget child;

  @override
  State<_WaveBody> createState() => _WaveBodyState();
}

class _WaveBodyState extends State<_WaveBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flatten = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _flatten,
    curve: Curves.easeInOut,
  );
  late final TopWaveClipper _waveClipper = TopWaveClipper(flattening: _curve);
  bool _isFlat = false;

  @override
  void dispose() {
    _curve.dispose();
    _flatten.dispose();
    super.dispose();
  }

  // Notifications, not a controller: the body may hold several lists (one
  // per tab), each with its own controller. ponytail: a tab switch sends
  // none, so the wave keeps the last list's state until the new one scrolls.
  bool _onScroll(ScrollNotification notification) {
    if (!widget.flattenOnScroll || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final bool flat = notification.metrics.pixels > 0;
    if (flat != _isFlat) {
      _isFlat = flat;
      flat ? _flatten.forward() : _flatten.reverse();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return ClipPath(
      clipper: _waveClipper,
      child: Container(
        color: colors.neutral500.withValues(alpha: 0.05),
        padding: const EdgeInsets.only(top: 5),
        child: ClipPath(
          clipper: _waveClipper,
          child: Container(
            padding: widget.padding,
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
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
