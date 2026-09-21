import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/utils/auth_guard.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_view.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/screens/favourites_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/home_view.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';
import 'package:nowdelivery_user_app/features/main/presentation/widgets/app_bottom_nav_bar.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/screens/my_order_screen.dart';
import 'package:nowdelivery_user_app/features/settings/presentation/screens/settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  static const Set<int> _loginRequiredTabs = <int>{1, 3};
  static const List<Widget> mainPages = <Widget>[
    HomeView(),
    FavouritesScreen(),
    CartView(canPop: false),
    MyOrderScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final int currentPageIndex = ref.watch(mainTabIndexProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Stack(
        children: [

          Offstage(
            offstage: currentPageIndex != 0,
            child: TickerMode(
              enabled: currentPageIndex == 0,
              child: mainPages[0],
            ),
          ),

          if (currentPageIndex != 0) mainPages[currentPageIndex],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: AppBottomNavBar(
          currentIndex: currentPageIndex,
          onIndexChanged: (int value) {
            if (_loginRequiredTabs.contains(value) &&
                redirectGuestToLogin(context)) {
              return;
            }
            ref.read(mainTabIndexProvider.notifier).state = value;
          },
        ),
      ),
    );
  }
}
