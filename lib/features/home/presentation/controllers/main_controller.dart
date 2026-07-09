import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:nowdelivery_user_app/features/favourites/favourites_interface.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/home_view.dart';
import 'package:nowdelivery_user_app/features/orders/orders_interface.dart';
import 'package:nowdelivery_user_app/features/settings/settings_screen.dart';
import 'package:nowdelivery_user_app/features/wallet/wallet_interface.dart';

final Provider<List<Widget>> mainPagesProvider = Provider(
  (ref) => [
    HomeView(),
    FavouritesScreen(),
    CartScreen(),
    MyOrderScreen(),
    SettingsScreen(),
  ],
);

final StateProvider<int> currentPageIndexProvider = StateProvider(
      (ref) => 0,
);
