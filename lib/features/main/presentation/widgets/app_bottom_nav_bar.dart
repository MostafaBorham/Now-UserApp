import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// Fully controlled by the parent: the highlighted tab always follows
/// [currentIndex], so a tap the parent decides not to honor (e.g. a guest
/// tapping a login-required tab) leaves the selection unchanged.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onIndexChanged,
    this.onCenterTap,
  });

  final int currentIndex;
  final ValueChanged<int>? onIndexChanged;
  final VoidCallback? onCenterTap;

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
                        Container(
                          alignment: Alignment.center,
                          width: stackCon.maxWidth * 0.15,
                          height: stackCon.maxWidth * 0.15,
                          decoration: BoxDecoration(
                            color: colors.primary500Main,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colors.neutral500.withValues(alpha: 0.3),
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