import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';

/// Asks, on the way to checkout, whether to trim [vendors]' lines down to the
/// stock that is left (see [CartVendorModel.stockFixes]).
///
/// Resolves to `true` to trim and go on to checkout; `false` or `null`
/// (dismissed) to stay in the cart.
Future<bool?> showCartNotReadySheet(
  BuildContext context,
  List<CartVendorModel> vendors,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.colors.white,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.7,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext sheetContext) => CartNotReadyView(
      vendors: vendors,
      onContinue: () => sheetContext.pop(true),
      onBackToCart: () => sheetContext.pop(false),
    ),
  );
}

/// The body of [showCartNotReadySheet]: every line that has to change, by
/// store, with what it will become.
class CartNotReadyView extends StatelessWidget {
  const CartNotReadyView({
    super.key,
    required this.vendors,
    required this.onContinue,
    required this.onBackToCart,
  });

  final List<CartVendorModel> vendors;
  final VoidCallback onContinue;
  final VoidCallback onBackToCart;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Only the lines scroll: the two answers stay in reach however
            // many lines there are.
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.secondary600.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            size: 24,
                            color: colors.orange900,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            LangKeys.someItemsUnavailableKey.tr(),
                            maxLines: 2,
                            style: AppTextStyles.style20Bold.copyWith(
                              color: colors.tertiaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    8.hSpace,
                    Text(
                      LangKeys.stockChangedForItemsKey.tr(),
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.outline,
                      ),
                    ),
                    for (final CartVendorModel cartVendor in vendors) ...[
                      12.hSpace,
                      Text(
                        context.getLocalizedApiText(cartVendor.vendor.name),
                        style: AppTextStyles.style12Bold.copyWith(
                          color: colors.tertiaryContainer,
                        ),
                      ),
                      for (final MapEntry<ProductModel, int> fix
                          in cartVendor.stockFixes.entries)
                        _StockFixTile(line: fix.key, quantity: fix.value),
                    ],
                  ],
                ),
              ),
            ),
            12.hSpace,
            Divider(height: 1, thickness: 1, color: colors.neutral200),
            PrimaryAppButton(
              title: LangKeys.continueWithAvailableItemsKey.tr(),
              titleStyle: AppTextStyles.style16Medium,
              onTap: onContinue,
            ),
            10.hSpace,
            UnPrimaryAppButton(
              title: LangKeys.backToCartKey.tr(),
              titleStyle: AppTextStyles.style16Medium,
              onTap: onBackToCart,
            ),
            10.hSpace,
            Text(
              LangKeys.reviewCartWithoutCheckoutKey.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.style12Regular.copyWith(
                color: colors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One line of the sheet: red when it goes, yellow when it shrinks to
/// [quantity].
class _StockFixTile extends StatelessWidget {
  const _StockFixTile({required this.line, required this.quantity});

  final ProductModel line;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isRemoved = quantity == 0;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isRemoved
            ? colors.red300Main.withValues(alpha: 0.1)
            : colors.secondary600.withValues(alpha: 0.1),
        borderRadius: AppBorderRadius.brCircular16,
      ),
      child: Row(
        spacing: 12,
        children: [
          ClipRRect(
            borderRadius: AppBorderRadius.brCircular8,
            child: AppCachedNetworkImage(
              imageUrl: line.images?.firstOrNull ?? '',
              width: 64,
              height: 64,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  context.getLocalizedApiText(line.name),
                  maxLines: 2,
                  style: AppTextStyles.style14SemiBold.copyWith(
                    color: colors.tertiaryContainer,
                  ),
                ),
                Text(
                  isRemoved
                      ? LangKeys.notAvailableKey.tr()
                      : LangKeys.onlyAvailableOfRequestedKey.tr(
                          namedArgs: <String, String>{
                            'available': '$quantity',
                            'requested': '${line.quantity ?? 0}',
                          },
                        ),
                  style: AppTextStyles.style12SemiBold.copyWith(
                    color: isRemoved ? colors.red400 : colors.orange900,
                  ),
                ),
                Text(
                  isRemoved
                      ? LangKeys.willBeRemovedFromOrderKey.tr()
                      : LangKeys.quantityWillBeReducedToKey.tr(
                          namedArgs: <String, String>{'quantity': '$quantity'},
                        ),
                  maxLines: 2,
                  style: AppTextStyles.style12Regular.copyWith(
                    color: colors.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
