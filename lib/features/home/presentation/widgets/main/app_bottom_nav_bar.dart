import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/common/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/common/presentation/styles/text_styles.dart';

class AppBottomNavBar extends StatefulWidget {
  const AppBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onIndexChanged,
    this.onCenterTap,
  });

  final int currentIndex;
  final ValueChanged<int>? onIndexChanged;
  final VoidCallback? onCenterTap;

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant AppBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _currentIndex = widget.currentIndex;
    }
  }

  void _changeIndex(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    widget.onIndexChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

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
              top: stackCon.maxHeight*0.022,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _NavItem(
                      isSelected: _currentIndex == 0,
                      label: LangKeys.homeKey.tr(),
                      selectedColor: colors.primary,
                      unselectedColor: colors.tertiaryContainer,
                      onTap: () => _changeIndex(0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _currentIndex == 0
                              ? Assets.media.images.svg.filledHomeIcon.svg(
                                  width: stackCon.maxWidth * 0.05,
                                  colorFilter: ColorFilter.mode(
                                    colors.secondary,
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
                              color: _currentIndex == 0
                                  ? colors.secondary
                                  : colors.tertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: _NavItem(
                      isSelected: _currentIndex == 1,
                      label: LangKeys.favouriteKey.tr(),
                      selectedColor: colors.primary,
                      unselectedColor: colors.tertiaryContainer,
                      onTap: () => _changeIndex(1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _currentIndex == 1
                              ? Assets.media.images.svg.filledFavouriteIcon.svg(
                                  width: stackCon.maxWidth * 0.05,
                                  colorFilter: ColorFilter.mode(
                                    colors.secondary,
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
                              color: _currentIndex == 1
                                  ? colors.secondary
                                  : colors.tertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: widget.onCenterTap,
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: stackCon.maxWidth * 0.15,
                          height: stackCon.maxWidth * 0.15,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                              color: colors.onSurface.withValues(alpha: 0.3),
                              spreadRadius: 5,
                              blurRadius: 6
                            )]
                          ),
                          child: Assets.media.images.svg.shoppingCartIcon.svg(
                            colorFilter: ColorFilter.mode(
                              colors.onPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _NavItem(
                      isSelected: _currentIndex == 2,
                      label: LangKeys.ordersKey.tr(),
                      selectedColor: colors.secondary,
                      unselectedColor: colors.tertiaryContainer,
                      onTap: () => _changeIndex(2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _currentIndex == 2
                              ? Assets.media.images.svg.filledOrdersIcon.svg(
                                  width: stackCon.maxWidth * 0.05,
                                  colorFilter: ColorFilter.mode(
                                    colors.secondary,
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
                              color: _currentIndex == 2
                                  ? colors.secondary
                                  : colors.tertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: _NavItem(
                      isSelected: _currentIndex == 3,
                      label: LangKeys.profileKey.tr(),
                      selectedColor: colors.secondary,
                      unselectedColor: colors.tertiaryContainer,
                      onTap: () => _changeIndex(3),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _currentIndex == 3
                              ? Assets.media.images.svg.filledAccountIcon.svg(
                                  width: stackCon.maxWidth * 0.05,
                                  colorFilter: ColorFilter.mode(
                                    colors.secondary,
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
                              color: _currentIndex == 3
                                  ? colors.secondary
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
