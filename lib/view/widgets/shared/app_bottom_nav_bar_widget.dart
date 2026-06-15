import 'package:flutter/material.dart';

/// One labelled tab in [AppBottomNavBar].
class NavItem {
  const NavItem({
    required this.label,
    required this.icon,
    IconData? activeIcon,
  }) : activeIcon = activeIcon ?? icon;

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// A floating bottom navigation bar with four labelled tabs split two-per-side
/// and an elevated circular action button (e.g. cart) punching through the
/// centre.
///
/// Usage:
/// ```dart
/// Scaffold(
///   extendBody: true,
///   body: ...,
///   bottomNavigationBar: AppBottomNavBar(
///     currentIndex: _index,
///     onTap: (i) => setState(() => _index = i),
///     onCartTap: _openCart,
///   ),
/// )
/// ```
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCartTap,
    this.items = AppBottomNavBar.defaultItems,
    this.cartIcon = Icons.shopping_cart_rounded,
    this.barColor = Colors.white,
    this.activeColor = const Color(0xFFF5B301),
    this.inactiveColor = const Color(0xFF3A3C40),
    this.cartGradient = const [Color(0xFF54CB63), Color(0xFF3FB84E)],
    this.barHeight = 66,
    this.cartSize = 58,
    this.floating = true,
  }) : assert(items.length == 4, 'AppBottomNavBar expects exactly 4 items');

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCartTap;
  final List<NavItem> items;
  final IconData cartIcon;
  final Color barColor;
  final Color activeColor;
  final Color inactiveColor;
  final List<Color> cartGradient;
  final double barHeight;
  final double cartSize;
  final bool floating;

  /// الرئيسية · المفضلة · [cart] · الطلبات · الحساب
  static const defaultItems = <NavItem>[
    NavItem(
      label: 'الرئيسية',
      icon: Icons.sell_outlined,
      activeIcon: Icons.sell_rounded,
    ),
    NavItem(
      label: 'المفضلة',
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite_rounded,
    ),
    NavItem(
      label: 'الطلبات',
      icon: Icons.shopping_basket_outlined,
      activeIcon: Icons.shopping_basket_rounded,
    ),
    NavItem(
      label: 'الحساب',
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final overflow = cartSize * 0.42;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final radius = floating
        ? BorderRadius.circular(28)
        : const BorderRadius.vertical(top: Radius.circular(24));

    return Padding(
      padding: EdgeInsets.only(
        left: floating ? 14 : 0,
        right: floating ? 14 : 0,
        bottom: (floating ? 12 : 0) + bottomInset,
      ),
      child: SizedBox(
        height: barHeight + overflow,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: barHeight,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _Tab(
                        item: items[0],
                        selected: currentIndex == 0,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        onTap: () => onTap(0),
                      ),
                    ),
                    Expanded(
                      child: _Tab(
                        item: items[1],
                        selected: currentIndex == 1,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        onTap: () => onTap(1),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    Expanded(
                      child: _Tab(
                        item: items[2],
                        selected: currentIndex == 2,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        onTap: () => onTap(2),
                      ),
                    ),
                    Expanded(
                      child: _Tab(
                        item: items[3],
                        selected: currentIndex == 3,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        onTap: () => onTap(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: _CartButton(
                  size: cartSize,
                  icon: cartIcon,
                  gradient: cartGradient,
                  onTap: onCartTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.item,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: activeColor.withOpacity(0.12),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? item.activeIcon : item.icon, color: color, size: 25),
            const SizedBox(height: 5),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                height: 1,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({
    required this.size,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final double size;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradient,
          ),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.45),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.44),
      ),
    );
  }
}
