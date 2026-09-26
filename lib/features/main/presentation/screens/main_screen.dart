import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/auth_guard.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_view.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/screens/favourites_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/home_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_rate_order_view.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';
import 'package:nowdelivery_user_app/features/main/presentation/widgets/app_bottom_nav_bar.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/screens/my_order_screen.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_order_to_rate_vm.dart';
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
    FavouritesScreen(canPop: false),
    CartView(canPop: false),
    MyOrderScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _offerRating();
    });
  }

  /// Offers to rate the last delivered order when it still needs one — once
  /// per order.
  ///
  /// Checked only as the shell opens: at launch, or on the fresh shell a login
  /// started from onboarding lands on. Both come after the user's dependencies
  /// have loaded, so the answer is already here. Reacting to the fetch itself
  /// would open the sheet over the OTP screen during a login started from
  /// inside the shell, and that screen's own pops would close the sheet instead
  /// of itself; such a login gets the prompt at the next launch.
  void _offerRating() {
    final OrderModel? order = ref.read(getOrderToRateProvider).valueOrNull;
    if (order == null) return;

    ref.read(getOrderToRateProvider.notifier).markPrompted();
    showRateOrderSheet(
      context,
      storeName: context.getLocalizedApiText(order.rating.vendor.name),
      storeLogoUrl: order.rating.vendor.imageUrl ?? '',
      onRate: () =>
          context.pushNamed(AppRoutes.orderRatingScreen, extra: order),
    );
  }

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
