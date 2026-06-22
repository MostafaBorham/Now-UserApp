import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/view/controllers/main/main_pages_controller.dart';

import '../../widgets/main/app_bottom_nav_bar.dart';

class MainLayoutScreen extends ConsumerWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final int currentPageIndex = ref.watch(currentPageIndexProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: ref.read(mainPagesProvider).elementAt(currentPageIndex),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: currentPageIndex,
        onItemSelected: (newPageIndex) {
          ref.read(currentPageIndexProvider.notifier).state = newPageIndex;
        },
        onCenterTap: () {
          // TODO: open cart
        },
        backgroundColor: colors.onPrimary,
        selectedColor: colors.secondary,
        unselectedColor: colors.onPrimaryFixed,
        centerButtonColor: colors.primary,
        centerIconColor: colors.onPrimary,
        items: const [
          BottomNavItemData(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'الرئيسية',
          ),
          BottomNavItemData(
            icon: Icons.favorite_border,
            activeIcon: Icons.favorite_rounded,
            label: 'المفضلة',
          ),
          BottomNavItemData(
            icon: Icons.shopping_basket_outlined,
            activeIcon: Icons.shopping_basket_rounded,
            label: 'الطلبات',
          ),
          BottomNavItemData(
            icon: Icons.person_outline,
            activeIcon: Icons.person_rounded,
            label: 'الحساب',
          ),
        ],
      ),
    );
  }
}
