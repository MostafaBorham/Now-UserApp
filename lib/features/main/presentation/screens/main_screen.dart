import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/auth_guard.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_view.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
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

class _MainScreenState extends ConsumerState<MainScreen>
    with SingleTickerProviderStateMixin {
  static const Set<int> _loginRequiredTabs = <int>{1, 3};
  static const List<Widget> mainPages = <Widget>[
    HomeView(),
    FavouritesScreen(canPop: false),
    CartView(canPop: false),
    MyOrderScreen(),
    SettingsScreen(),
  ];

  /// Fades the body in on every tab switch, which used to cut straight to the
  /// new tab. Opaque at rest, so it only costs anything for its 220 ms.
  late final AnimationController _tabFade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );
  late final Animation<double> _tabOpacity = CurvedAnimation(
    parent: _tabFade,
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _tabFade.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // The splash no longer waits for the launch fetch: if it is still on its
      // way, offer once it lands.
      if (ref.read(getOrderToRateProvider).isLoading) {
        late final ProviderSubscription<AsyncValue<OrderModel?>> sub;
        sub = ref.listenManual(getOrderToRateProvider, (_, next) {
          if (next.isLoading) return;
          sub.close();
          _offerRating();
        });
      } else {
        _offerRating();
      }
    });
  }

  /// Offers to rate the last delivered order when it still needs one — once
  /// per order.
  ///
  /// Only for the fetch already settled or on its way as the shell opens: at
  /// launch, or on the fresh shell a login started from onboarding lands on.
  /// Reacting to any later fetch would open the sheet over the OTP screen
  /// during a login started from inside the shell, and that screen's own pops
  /// would close the sheet instead of itself; such a login gets the prompt at
  /// the next launch.
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
    // Any switch, from the bar, back, or another screen setting the tab.
    ref.listen<int>(mainTabIndexProvider, (int? previous, int next) {
      if (previous != next) _tabFade.forward(from: 0);
    });

    // Cart badge count — rebuilds only when the total changes. getCartProvider
    // is session-scoped, so it clears with the signed-in user (no stale count).
    final int cartItemCount = ref.watch(
      getCartProvider.select(
        (AsyncValue<CartModel> state) => state.valueOrNull?.itemCount ?? 0,
      ),
    );

    // `/main` is reached with `go`, so it is the only route: back on another
    // tab returns to Home, and only Home's back leaves the app.
    return PopScope(
      canPop: currentPageIndex == 0,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) ref.read(mainTabIndexProvider.notifier).state = 0;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        // Home stays mounted (Offstage) under the fade, so its state survives.
        body: FadeTransition(
          opacity: _tabOpacity,
          child: Stack(
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
        ),
        bottomNavigationBar: SafeArea(
          child: AppBottomNavBar(
            currentIndex: currentPageIndex,
            cartItemCount: cartItemCount,
            onIndexChanged: (int value) {
              if (_loginRequiredTabs.contains(value) &&
                  redirectGuestToLogin(context)) {
                return;
              }
              ref.read(mainTabIndexProvider.notifier).state = value;
            },
          ),
        ),
      ),
    );
  }
}
