import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/screens/favourites_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/home_view.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/screens/my_order_screen.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/screens/wallet_screen.dart';

final Provider<List<Widget>> mainPagesProvider = Provider(
  (ref) => [
    HomeView(),
    FavouritesScreen(),
    MyOrderScreen(),
    WalletScreen(),
  ],
);

final StateProvider<int> currentPageIndexProvider = StateProvider(
      (ref) => 0,
);
