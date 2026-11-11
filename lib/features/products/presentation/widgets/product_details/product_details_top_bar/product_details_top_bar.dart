import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/details_top_bar_buttons.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/top_bars/details_top_bar_curtain.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_top_bar/widgets/product_top_bar_title.dart';

class ProductDetailsTopBar extends StatelessWidget {
  const ProductDetailsTopBar({
    super.key,
    required this.productDetailsState,
    required this.onCartTap,
    required this.isProductNamePinned,
    required this.titleProgress,
    required this.productNameShift,
    this.showCloseButton = false,
  });

  final AsyncValue<ProductModel> productDetailsState;
  final VoidCallback onCartTap;
  final ValueListenable<bool> isProductNamePinned;
  final ValueListenable<double> titleProgress;
  final ValueListenable<double> productNameShift;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final double buttonSize = MediaQuery.sizeOf(context).width * 0.05;
    final ProductModel? product = productDetailsState.valueOrNull;
    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ValueListenableBuilder<bool>(
              valueListenable: isProductNamePinned,
              builder: (_, bool isPinned, _) =>
                  DetailsTopBarCurtain(isShown: isPinned),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Container(
              height: kToolbarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (product != null)
                    ListenableBuilder(
                      listenable: Listenable.merge([
                        titleProgress,
                        productNameShift,
                      ]),
                      builder: (_, _) => titleProgress.value == 0
                          ? const SizedBox.shrink()
                          : ProductTopBarTitle(
                              name: context.getLocalizedApiText(product.name),
                              progress: titleProgress.value,
                              shift: productNameShift.value,
                              horizontalInset: buttonSize * 4 + 16,
                            ),
                    ),
                  DetailsTopBarButtons(
                    showCloseButton: showCloseButton,
                    buttonSize: buttonSize,
                    favouriteType: FavouriteType.product,
                    favouriteState: productDetailsState.whenData(
                      (ProductModel product) => product.isFavorite ?? false,
                    ),
                    favouriteItemId: product?.id,
                    onCartTap: onCartTap,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
