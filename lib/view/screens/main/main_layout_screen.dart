import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/view/controllers/main/main_pages_controller.dart';
import 'package:nowdelivery_user_app/view/screens/home/home_screen.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/app_bottom_nav_bar.dart';

class MainLayoutScreen extends ConsumerWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final int currentPageIndex = ref.watch(currentPageIndexProvider);
    return Scaffold(
      extendBody: true,
      body: ref.read(mainPagesProvider).elementAt(currentPageIndex),
      backgroundColor: colors.onSecondaryFixed,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentPageIndex,
        onTap: (newPageIndex) {
          ref.read(currentPageIndexProvider.notifier).state = newPageIndex;
        },
        barColor: colors.onPrimary,
        onCartTap: () => Navigator.pushNamed(context, '/cart'),
      ),
    );
  }
}