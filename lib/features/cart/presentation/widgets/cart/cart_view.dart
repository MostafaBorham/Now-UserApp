import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/blocking_loading_overlay.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_item_card/cart_brand_item_card.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_empty_view.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_shimmer_view.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';







class CartView extends ConsumerStatefulWidget {
  const CartView({super.key, this.canPop});








  final bool? canPop;

  @override
  ConsumerState<CartView> createState() => _CartViewState();
}

class _CartViewState extends ConsumerState<CartView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(getCartProvider).hasValue) {
        ref.read(getCartProvider.notifier).getCart();
      }
    });
  }








  Future<void> _checkout({int? vendorId}) async {
    final CheckoutViewModel checkoutVm = ref.read(checkoutProvider.notifier);

    final String? error = vendorId == null
        ? await checkoutVm.checkout()
        : await checkoutVm.checkoutForSingleStore(vendorId: vendorId);

    if (!mounted) return;

    if (error != null) {
      AppToast.showError(context, error);
      return;
    }






    context.pushNamed(AppRoutes.checkoutScreen, extra: vendorId);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<CartModel> cartState = ref.watch(getCartProvider);



    final bool isCheckingOut = ref.watch(
      checkoutProvider.select(
        (AsyncValue<CheckoutModel?> state) => state.isLoading,
      ),
    );

    return BlockingLoadingOverlay(
      isLoading: isCheckingOut,
      child: AppWavedView(
        appBarTitle: LangKeys.cartKey.tr(),
        canPop: widget.canPop,
        scrollController: _scrollController,
        body: cartState.when(
          loading: () => CartShimmerView(),
          error: (Object error, StackTrace stackTrace) =>
              ServerConnectionErrorWidget(
                message: error.toString(),
                onRetry: () => ref.read(getCartProvider.notifier).getCart(),
              ),
          data: (CartModel cart) {


            final List<CartVendorModel> vendors = cart.vendors
                .where((CartVendorModel v) => v.vendor.id != null)
                .toList();

            return AppRefreshIndicator(
              onRefresh: () async =>
                  ref.read(getCartProvider.notifier).getCart(),
              child: vendors.isEmpty
                  ? const CartEmptyView()
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            controller: _scrollController,




                            physics: const AlwaysScrollableScrollPhysics(),



                            padding: const EdgeInsets.fromLTRB(3, 57, 3, 20),
                            itemBuilder: (context, index) {
                              final CartVendorModel cartVendor = vendors[index];

                              return CartBrandItemCard(
                                cartVendor: cartVendor,
                                onCheckout: () => _checkout(
                                  vendorId: cartVendor.vendor.id!,
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return 20.hSpace;
                            },
                            itemCount: vendors.length,
                          ),
                        ),
                        PrimaryAppButton(
                          title: LangKeys.checkoutKey.tr(),
                          onTap: () => _checkout(),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
