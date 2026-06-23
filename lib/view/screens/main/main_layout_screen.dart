import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/common/route/app_routes.dart';
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
      extendBody: false,
      body: ref.read(mainPagesProvider).elementAt(currentPageIndex),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AppBottomNavBar(currentIndex: currentPageIndex, onIndexChanged: (int value) {
          ref.read(currentPageIndexProvider.notifier).state = value;
        },onCenterTap: () => Navigator.pushNamed(context, AppRoutes.categoriesScreen),),
      ),
    );
  }
}