import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';




class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onIndexChanged,
    this.onCenterTap,
    this.cartItemCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int>? onIndexChanged;
  final VoidCallback? onCenterTap;

  /// Number of units in the cart, shown as a badge on the center cart button.
  /// `0` hides the badge.
  final int cartItemCount;

  void _changeIndex(int index) {
    HapticFeedback.lightImpact();

    if (currentIndex == index) return;

    onIndexChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return LayoutBuilder(
      builder: (context, stackCon) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              width: double.infinity,
              child: Assets.media.images.png.bottomNavBarBackground.image(
                fit: BoxFit.fitWidth,
              ),
            ),

            Positioned.fill(
              top: stackCon.maxHeight * 0.022,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _NavItem(
                      isSelected: currentIndex == 0,
                      label: LangKeys.homeKey.tr(),
                      selectedColor: colors.primary500Main,
                      unselectedColor: colors.tertiaryContainer,
                      onTap: () => _changeIndex(0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          currentIndex == 0
                              ? Assets.media.images.svg.filledHomeIcon.svg(
                                  width: stackCon.maxWidth * 0.05,
                                  colorFilter: ColorFilter.mode(
                                    colors.secondary600,
                                    BlendMode.srcIn,
                                  ),
                                )
                              : Assets.media.images.svg.borderdHomeIcon.svg(
                                  width: stackCon.maxWidth * 0.05,
                                  colorFilter: ColorFilter.mode(
                                    colors.tertiaryContainer,
                                    BlendMode.srcIn,
                                  ),
                                ),
                          const SizedBox(height: 5),
                          Text(
                            LangKeys.homeKey.tr(),
                            style: AppTextStyles.style12Medium.copyWith(
                              color: currentIndex == 0
                                  ? colors.secondary600
                                  : colors.tertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: _NavItem(
                      isSelected: currentIndex == 1,
                      label: LangKeys.favouriteKey.tr(),
                      selectedColor: colors.primary500Main,
                      unselectedColor: colors.tertiaryContainer,
                      onTap: () => _changeIndex(1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          currentIndex == 1
                              ? Assets.media.images.svg.filledFavouriteIcon.svg(
                                  width: stackCon.maxWidth * 0.05,
                                  colorFilter: ColorFilter.mode(
                                    colors.secondary600,
                                    BlendMode.srcIn,
                                  ),
                                )
                              : Assets.media.images.svg.favouriteIcon.svg(
                                  width: stackCon.maxWidth * 0.05,
                                  colorFilter: ColorFilter.mode(
                                    colors.tertiaryContainer,
                                    BlendMode.srcIn,
                                  ),
                                ),
                          const SizedBox(height: 5),
                          Text(
                            LangKeys.favouriteKey.tr(),
                            style: AppTextStyles.style12Medium.copyWith(
                              color: currentIndex == 1
                                  ? colors.secondary600
                                  : colors.tertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () => _changeIndex(2),
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: stackCon.maxWidth * 0.15,
                              height: stackCon.maxWidth * 0.15,
                              decoration: BoxDecoration(
                                color: colors.primary500Main,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        colors.neutral500.withValues(alpha: 0.3),
                                    spreadRadius: 5,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: currentIndex==2? Assets.media.images.svg.filledCartIcon.svg(
                                colorFilter: ColorFilter.mode(
                                  colors.white,
                                  BlendMode.srcIn,
                                ),
                              ) : Assets.media.images.svg.shoppingCartIcon.svg(
                                colorFilter: ColorFilter.mode(
                                  colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            if (cartItemCount > 0)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: _CartBadge(count: cartItemCount),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _NavItem(
                      isSelected: currentIndex == 3,
                      label: LangKeys.ordersKey.tr(),
                      selectedColor: colors.secondary600,
                      unselectedColor: colors.tertiaryContainer,
                      onTap: () => _changeIndex(3),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          currentIndex == 3
                              ? Assets.media.images.svg.filledOrdersIcon.svg(
                                  width: stackCon.maxWidth * 0.05,
                                  colorFilter: ColorFilter.mode(
                                    colors.secondary600,
                                    BlendMode.srcIn,
                                  ),
                                )
                              : Assets.media.images.svg.ordersIcon.svg(
                                  width: stackCon.maxWidth * 0.05,
                                  colorFilter: ColorFilter.mode(
                                    colors.tertiaryContainer,
                                    BlendMode.srcIn,
                                  ),
                                ),
                          const SizedBox(height: 5),
                          Text(
                            LangKeys.ordersKey.tr(),
                            style: AppTextStyles.style12Medium.copyWith(
                              color: currentIndex == 3
                                  ? colors.secondary600
                                  : colors.tertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: _NavItem(
                      isSelected: currentIndex == 4,
                      label: LangKeys.profileKey.tr(),
                      selectedColor: colors.secondary600,
                      unselectedColor: colors.tertiaryContainer,
                      onTap: () => _changeIndex(4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          currentIndex == 4
                              ? Assets.media.images.svg.filledAccountIcon.svg(
                                  width: stackCon.maxWidth * 0.05,
                                  colorFilter: ColorFilter.mode(
                                    colors.secondary600,
                                    BlendMode.srcIn,
                                  ),
                                )
                              : Assets.media.images.svg.borderdAccountIcon.svg(
                                  width: stackCon.maxWidth * 0.05,
                                  colorFilter: ColorFilter.mode(
                                    colors.tertiaryContainer,
                                    BlendMode.srcIn,
                                  ),
                                ),
                          const SizedBox(height: 5),
                          Text(
                            LangKeys.profileKey.tr(),
                            style: AppTextStyles.style12Medium.copyWith(
                              color: currentIndex == 4
                                  ? colors.secondary600
                                  : colors.tertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The item-count badge on the center cart button: a white pill with the count
/// in the brand color, capped at `99+`.
class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final String label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: colors.primary500Main, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.style12Medium.copyWith(
          color: colors.primary500Main,
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.child,
    required this.onTap,
    required this.isSelected,
    required this.label,
    required this.selectedColor,
    required this.unselectedColor,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool isSelected;
  final String label;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, child: child);
  }
}
