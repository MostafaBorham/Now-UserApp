import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/screens/favourites_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/home_view.dart';
import 'package:nowdelivery_user_app/features/main/presentation/widgets/app_bottom_nav_bar.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/screens/my_order_screen.dart';
import 'package:nowdelivery_user_app/features/settings/settings_screen.dart';
import 'package:nowdelivery_user_app/features/welcome/data/datasources/local/cache/welcome_cache_service.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Set<int> _loginRequiredTabs = <int>{1, 3};
  final List<Widget> mainPages = [
    HomeView(),
    FavouritesScreen(),
    CartScreen(),
    MyOrderScreen(),
    SettingsScreen(),
  ];

  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: false,
      body: mainPages.elementAt(currentPageIndex),
      bottomNavigationBar: SafeArea(
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
          setState(() {
            currentPageIndex = value;
          });
        }),
      ),
    );
  }
}