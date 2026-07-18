import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/screens/main/app_bottom_nav_bar.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/main_controller.dart';
import 'package:nowdelivery_user_app/features/welcome/data/datasources/local/cache/welcome_cache_service.dart';


class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  /// Bottom-nav tabs that require a logged-in user: favourites (1),
  /// orders (3) and profile (4). A guest tapping one of these is sent to
  /// the phone login screen instead; the current tab stays selected.
  static const Set<int> _loginRequiredTabs = <int>{1, 3, 4};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentPageIndex = ref.watch(currentPageIndexProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: false,
      body: ref.read(mainPagesProvider).elementAt(currentPageIndex),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AppBottomNavBar(currentIndex: currentPageIndex, onIndexChanged: (int value) {
          if (_loginRequiredTabs.contains(value)) {
            final Map<String, dynamic> tokenData =
                WelcomeCacheService().getToken();
            final bool isGuest =
                tokenData[CacheKeys.isGuest] as bool? ?? true;

            if (isGuest) {
              context.pushNamed(AppRoutes.phoneVerificationScreen);
              return;
            }
          }
          ref.read(currentPageIndexProvider.notifier).state = value;
        }),
      ),
    );
  }
}