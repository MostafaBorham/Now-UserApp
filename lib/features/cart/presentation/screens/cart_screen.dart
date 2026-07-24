import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_view.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CartView());
  }
}
