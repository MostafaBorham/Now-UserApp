import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/rate_order_request_model.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/order_rating_section.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/rate_order_vm.dart';

/// Lets the shopper rate a delivered [order]: a star rating plus an optional
/// comment for every line item, the courier and the store. The committed
/// ratings and the comment controllers are held here; the star rows and comment
/// boxes are stateless and report back through callbacks.
class OrderRatingScreen extends ConsumerStatefulWidget {
  const OrderRatingScreen({super.key, required this.order});

  final OrderModel order;

  @override
  ConsumerState<OrderRatingScreen> createState() => _OrderRatingScreenState();
}

class _OrderRatingScreenState extends ConsumerState<OrderRatingScreen> {
  final ScrollController _scrollController = ScrollController();

  late final List<ProductModel> _products = widget.order.items;
  late final List<int> _productRatings = List<int>.filled(
    _products.length,
    0,
  );
  late final List<TextEditingController> _productComments =
      List<TextEditingController>.generate(
        _products.length,
        (_) => TextEditingController(),
      );

  final TextEditingController _courierComment = TextEditingController();
  final TextEditingController _storeComment = TextEditingController();
  int _courierRating = 0;
  int _storeRating = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    for (final TextEditingController controller in _productComments) {
      controller.dispose();
    }
    _courierComment.dispose();
    _storeComment.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final int? orderId = widget.order.id;
    final bool allProductsRated =
        _productRatings.every((int rating) => rating >= 1);
    final bool storeRated = _storeRating >= 1;
    final bool courierRated = _courierRating >= 1;

    if (orderId == null || !allProductsRated || !storeRated || !courierRated) {
      AppToast.showError(context, LangKeys.ratingRequiredKey.tr());
      return;
    }

    final RateOrderRequest request = RateOrderRequest.build(
      orderId: orderId,
      productIds: _products
          .map((ProductModel product) => product.productId ?? product.id)
          .toList(),
      productRatings: _productRatings,
      productComments: _productComments
          .map((TextEditingController controller) => controller.text)
          .toList(),
      vendorId: widget.order.vendorId ?? widget.order.vendor.id,
      vendorRating: _storeRating,
      vendorComment: _storeComment.text,
      deliveryId: widget.order.driver?.id,
      deliveryRating: _courierRating,
      deliveryComment: _courierComment.text,
    );

    final String? errorMessage = await ref
        .read(rateOrderProvider(widget.order.uuid ?? '').notifier)
        .rateOrder(request: request);

    if (!mounted) return;

    if (errorMessage != null) {
      AppToast.showError(context, errorMessage);
      return;
    }

    AppToast.showSuccess(context, LangKeys.thanksForRatingKey.tr());
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final String commentHint = '${LangKeys.writeYourCommentHereKey.tr()}...';
    final bool isSubmitting = ref
        .watch(rateOrderProvider(widget.order.uuid ?? ''))
        .isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AppWavedView(
        appBarTitle: LangKeys.orderRatingKey.tr(),
        canPop: true,
        scrollController: _scrollController,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            spacing: 12,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 57),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            LangKeys.theRatingKey.tr(),
                            style: AppTextStyles.style16Medium.copyWith(
                              color: colors.black,
                            ),
                          ),
                          Text(
                            LangKeys.shareExperienceToImproveKey.tr(),
                            style: AppTextStyles.style12Regular.copyWith(
                              color: colors.neutral400,
                            ),
                          ),
                        ],
                      ),
                      OrderRatingSection(
                        products: _products,
                        productRatings: _productRatings,
                        productComments: _productComments,
                        courierRating: _courierRating,
                        storeRating: _storeRating,
                        commentHint: commentHint,
                        courierComment: _courierComment,
                        storeComment: _storeComment,
                        onProductRatingSelected: (int index, int value) =>
                            setState(() => _productRatings[index] = value),
                        onCourierRatingSelected: (int value) =>
                            setState(() => _courierRating = value),
                        onStoreRatingSelected: (int value) =>
                            setState(() => _storeRating = value),
                      ),
                    ],
                  ),
                ),
              ),
              PrimaryAppButton(
                title: LangKeys.submitRatingKey.tr(),
                isLoading: isSubmitting,
                onTap: _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
