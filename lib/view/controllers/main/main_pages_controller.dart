import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/view/screens/home/home_screen.dart';
import 'package:nowdelivery_user_app/view/screens/order/my_order_screen.dart';

final Provider<List<Widget>> mainPagesProvider = Provider(
  (ref) => [
    HomeScreen(),
    Container(width: double.infinity, height: 100, color: Colors.red),
    MyOrderScreen(),
    Container(width: double.infinity, height: 100, color: Colors.blue),
  ],
);

final StateProvider<int> currentPageIndexProvider = StateProvider(
      (ref) => 0,
);
