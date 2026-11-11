import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_quantity_provider.dart';

/// The redesigned stepper shares the live stock limit used by add-to-cart.
final productMaxQuantityProvider = Provider.autoDispose<int>(
  (ref) => ref.watch(productRemainingProvider) ?? 0x7fffffff,
  dependencies: [productRemainingProvider],
);
