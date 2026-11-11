import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_max_quantity_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_model_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_action_buttons.dart';

class ProductDetailsBottomBar extends ConsumerWidget {
  const ProductDetailsBottomBar({super.key, required this.onQuantityRejected});

  final VoidCallback onQuantityRejected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final ProductModel product = ref.watch(productProvider);
    if (product.id == null || ref.watch(productMaxQuantityProvider) < 1) {
      return const SizedBox.shrink();
    }
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Container(
            color: colors.neutral500.withValues(alpha: 0.3),
            width: double.infinity,
            height: 1,
          ),
          ProductActionButtons(
            onQuantityRejected: onQuantityRejected,
            productId: product.id!,
            productName: context.getLocalizedApiText(product.name),
            productImageUrl: (product.images?.isNotEmpty ?? false)
                ? product.images!.first
                : '',
          ),
        ],
      ),
    );
  }
}
