import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/view/screens/favourites/favourites_screen.dart';
import 'package:nowdelivery_user_app/view/screens/home/home_screen.dart';
import 'package:nowdelivery_user_app/view/screens/order/my_order_screen.dart';
import 'package:nowdelivery_user_app/view/screens/wallet/wallet_screen.dart';

final Provider<List<Widget>> mainPagesProvider = Provider(
  (ref) => [
    HomeScreen(),
    FavouritesScreen(),
    MyOrderScreen(),
    WalletScreen(),
  ],
);

final StateProvider<int> currentPageIndexProvider = StateProvider(
      (ref) => 0,
);
