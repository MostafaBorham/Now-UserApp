import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/dialogs/app_custom_alert_dialog.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_invoice_summary_card.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_product_item_view.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/delete_cart_vendor_vm.dart';

/// The expanded body of a store's cart card: its lines, a way back into the
/// store, and the invoice breakdown.
class CartBrandItemDetailsView extends StatelessWidget {
  const CartBrandItemDetailsView({
    super.key,
    required this.products,
    required this.pricing,
    required this.store,
  });

  final List<ProductModel> products;
  final CartVendorPricingModel pricing;
  final StoreModel store;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final int? vendorId = store.id;

    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: InkWell(
            onTap: vendorId == null
                ? null
                : () => _confirmDeleteStore(context, vendorId),
            child: Text(
              LangKeys.deleteAllKey.tr(),
              style: AppTextStyles.style14Bold.copyWith(
                color: colors.errorContainer,
              ),
            ),
          ),
        ),

        ListView.separated(
          // A null padding takes the screen's insets — under the main shell
          // that includes the nav bar — as a gap under the items (BUG-038).
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) =>
              CartProductItemView(product: products[index]),
          separatorBuilder: (context, index) => 16.hSpace,
          itemCount: products.length,
        ),

        InkWell(
          onTap: vendorId == null
              ? null
              : () => context.pushNamed(
                  AppRoutes.storeDetailsScreen,
                  pathParameters: <String, String>{'id': '$vendorId'},
                  extra: store.name,
                ),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                Assets.media.images.svg.circleAddMoreBrokenIcon.svg(),
                Text(
                  LangKeys.addMoreItemsKey.tr(),
                  style: AppTextStyles.style14Medium.copyWith(
                    color: colors.neutral1200,
                  ),
                ),
              ],
            ),
          ),
        ),

        StoreInvoiceSummaryCard(
          subtotal: pricing.subtotal,
          tax: pricing.tax,
          deliveryFee: pricing.deliveryFee,
          discount: pricing.discount,
        ),
      ],
    );
  }

  /// Asks before emptying the whole store out of the cart.
  ///
  /// The dialog owns the request so it can show its own spinner, and follows
  /// [AppCustomAlertDialog]'s contract: it closes itself on success and stays
  /// open, with the reason inside it, on failure.
  void _confirmDeleteStore(BuildContext context, int vendorId) {
    AppCustomAlertDialog.show(
      context,
      (BuildContext dialogContext) => Consumer(
        builder: (BuildContext consumerContext, WidgetRef ref, _) {
          ref.listen<AsyncValue<CartModel?>>(
            deleteCartVendorProvider(vendorId),
            (AsyncValue<CartModel?>? previous, AsyncValue<CartModel?> next) {
              next.whenOrNull(
                data: (CartModel? cart) {
                  if (cart == null) return;
                  dialogContext.pop();
                },
                // Deliberately does not pop: this used to close the dialog and
                // then toast on `consumerContext`, which the pop had already
                // torn down. The dialog stays up with its spinner cleared, so
                // the shopper can read the reason and retry or cancel.
                error: (Object error, StackTrace _) =>
                    AppToast.showError(consumerContext, error.toString()),
              );
            },
          );

          final bool isDeleting = ref.watch(
            deleteCartVendorProvider(
              vendorId,
            ).select((AsyncValue<CartModel?> state) => state.isLoading),
          );

          return AppCustomAlertDialog(
            title: LangKeys.removeItemFromCartKey.tr(),
            message: LangKeys.removeItemFromCartConfirmationKey.tr(),
            confirmLabel: LangKeys.deleteKey.tr(),
            isLoading: isDeleting,
            onConfirm: () => ref
                .read(deleteCartVendorProvider(vendorId).notifier)
                .deleteCartVendor(),
          );
        },
      ),
    );
  }
}
