import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/selectable_rating_stars.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_rating_model.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/order_rating/order_rating_product_row.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/order_rating/order_rating_subject_section.dart';

/// Reports the tapped star for the product at [index], `1`–5.
typedef ProductRatingSelectedCallback = void Function(int index, int rating);

/// The rateable body shared by [OrderRatingScreen] and [OrderRatingView]: the
/// products card followed by the courier and store subject sections, each only
/// when there is one to show ([showCourier], [showStore]). It owns no
/// state — the committed ratings and comment controllers live on the caller,
/// which passes them back in and receives taps through the callbacks. Pass
/// [readOnly] (and null callbacks) for the dimmed, display-only variant.
class OrderRatingSection extends StatelessWidget {
  const OrderRatingSection({
    super.key,
    required this.products,
    required this.productRatings,
    required this.courierRating,
    required this.storeRating,
    required this.commentHint,
    required this.showCourier,
    required this.showStore,
    this.productComments,
    this.courierComment,
    this.storeComment,
    this.onProductRatingSelected,
    this.onCourierRatingSelected,
    this.onStoreRatingSelected,
    this.readOnly = false,
  });

  final List<RatedProductModel> products;
  final List<int> productRatings;
  final int courierRating;
  final int storeRating;
  final String commentHint;
  final bool showCourier;
  final bool showStore;
  final List<TextEditingController>? productComments;
  final TextEditingController? courierComment;
  final TextEditingController? storeComment;
  final ProductRatingSelectedCallback? onProductRatingSelected;
  final RatingSelectedCallback? onCourierRatingSelected;
  final RatingSelectedCallback? onStoreRatingSelected;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        if (products.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                colors: [colors.secondary100, colors.primary100],
              ),
              borderRadius: AppBorderRadius.brCircular8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                Text(
                  LangKeys.rateProductsKey.tr(),
                  style: AppTextStyles.style14Bold.copyWith(color: colors.black),
                ),
                for (int i = 0; i < products.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: colors.neutral300,
                    ),
                  OrderRatingProductRow(
                    name: context.getLocalizedApiText(products[i].name),
                    imageUrl: products[i].imageUrl ?? '',
                    rating: productRatings[i],
                    commentHint: commentHint,
                    commentController: productComments?[i],
                    readOnly: readOnly,
                    onRatingSelected: onProductRatingSelected == null
                        ? null
                        : (int value) => onProductRatingSelected!(i, value),
                  ),
                ],
              ],
            ),
          ),
        if (showCourier)
          OrderRatingSubjectSection(
            title: LangKeys.deliveryAgentKey.tr(),
            rating: courierRating,
            commentHint: commentHint,
            commentController: courierComment,
            readOnly: readOnly,
            onRatingSelected: onCourierRatingSelected,
          ),
        if (showStore)
          OrderRatingSubjectSection(
            title: LangKeys.storeKey.tr(),
            rating: storeRating,
            commentHint: commentHint,
            commentController: storeComment,
            readOnly: readOnly,
            onRatingSelected: onStoreRatingSelected,
          ),
      ],
    );
  }
}
