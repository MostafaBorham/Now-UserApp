import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/dialogs/app_custom_alert_dialog.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_product_item_view.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/delete_cart_vendor_vm.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';

import '../../../../../core/presentation/widgets/store_invoice_summary_card.dart';

class CartBrandItemDetailsView extends StatelessWidget {
  const CartBrandItemDetailsView({
    super.key,
    this.products,
    this.pricing,
    this.store,
  });



  final List<ProductModel>? products;


  final CartVendorPricingModel? pricing;


  final StoreModel? store;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final int? vendorId = store?.id;
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: InkWell(


            onTap: vendorId == null
                ? null
                : () => AppCustomAlertDialog.show(
                    context,





                    (BuildContext dialogContext) => Consumer(
                      builder: (BuildContext consumerContext, WidgetRef ref, _) {
                        ref.listen<AsyncValue<CartModel?>>(
                          deleteCartVendorProvider(vendorId),
                          (
                            AsyncValue<CartModel?>? previous,
                            AsyncValue<CartModel?> next,
                          ) {
                            next.whenOrNull(
                              data: (CartModel? cart) {
                                if (cart == null) return;
                                Navigator.of(dialogContext).pop();
                              },
                              error: (Object error, StackTrace _) {
                                Navigator.of(dialogContext).pop();
                                AppToast.showError(
                                  consumerContext,
                                  error.toString(),
                                );
                              },
                            );
                          },
                        );

                        final bool isDeleting = ref.watch(
                          deleteCartVendorProvider(vendorId).select(
                            (AsyncValue<CartModel?> state) => state.isLoading,
                          ),
                        );

                        return AppCustomAlertDialog(
                          title: LangKeys.removeItemFromCartKey.tr(),
                          message:
                              LangKeys.removeItemFromCartConfirmationKey.tr(),
                          confirmLabel: LangKeys.deleteKey.tr(),
                          isLoading: isDeleting,
                          onConfirm: () => ref
                              .read(deleteCartVendorProvider(vendorId).notifier)
                              .deleteCartVendor(),
                        );
                      },
                    ),
                  ),
            child: Text(
              LangKeys.deleteAllKey.tr(),
              style: AppTextStyles.style14Bold.copyWith(
                color: colors.errorContainer,
              ),
            ),
          ),
        ),

        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return CartProductItemView(
              product: products?.elementAtOrNull(index),
              vendorName: store?.name,
            );
          },
          separatorBuilder: (context, index) => 16.hSpace,
          itemCount: products?.length ?? 3,
        ),

        InkWell(
          onTap: () =>
              context.pushNamed(AppRoutes.storeDetailsScreen, extra: store?.id),
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
          subtotal: pricing?.subtotal,
          tax: pricing?.tax,
          deliveryFee: pricing?.deliveryFee,
          discount: pricing?.discount,
        ),
      ],
    );
  }
}
