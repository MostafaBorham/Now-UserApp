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

class AppWavedView extends StatefulWidget {
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
    this.scrollController, this.leading,
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
  final EdgeInsets? bodyPadding;
  final ScrollController? scrollController;

  @override
  State<AppWavedView> createState() => _AppWavedViewState();
}

class _AppWavedViewState extends State<AppWavedView> {
  bool _isFlattened = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final ScrollController? controller = widget.scrollController;
    if (controller == null || !controller.hasClients) return;
    final bool flattened = controller.offset > 0;
    if (flattened != _isFlattened) {
      setState(() => _isFlattened = flattened);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Size screenSize = MediaQuery.sizeOf(context);
    final EdgeInsets bodyPadding =
        widget.bodyPadding ??
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 57,
        ).copyWith(bottom: 20);


    final EdgeInsets effectiveBodyPadding = widget.scrollController != null
        ? bodyPadding.copyWith(top: 0)
        : bodyPadding;


    final TopWaveClipper? waveClipper = _isFlattened
        ? null
        : const TopWaveClipper();
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
                  widget.leading?? (widget.canPop ?? context.canPop()
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
                      : const SizedBox.shrink()),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: widget.loadAppBarTitle
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
                              widget.appBarTitle,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                              style: AppTextStyles.style24SemiBold.copyWith(
                                color: colors.black,
                                fontSize: screenSize.width*0.05,
                              ),
                            ),
                    ),
                  ),
                  widget.hasCartIcon || widget.hasSupportIcon
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: [
                            if (widget.hasSupportIcon)
                              CircularSupportIcon(
                                size: screenSize.width * 0.05,
                                onTap:
                                    widget.onSupportTap ??
                                    () {
                                      context.pushNamed(
                                        AppRoutes.supportScreen,
                                      );
                                    },
                              ),
                            if (widget.hasCartIcon)
                              ReverseWidget(
                                child: CircularCartButton(
                                  size: screenSize.width * 0.05,
                                  onTap:
                                      widget.onCartTap ??
                                      () {
                                        context.pushNamed(AppRoutes.cartScreen);
                                      },
                                ),
                              ),
                          ],
                        )
                      : const SizedBox.shrink(),
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
                      child: widget.body,
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
