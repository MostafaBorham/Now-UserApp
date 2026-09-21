import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_rating_model.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/order_rating_section.dart';

/// The read-only "already rated" state shown in place of the rate-order button
/// when [OrderRatingModel.canRate] is false: a "thanks for rating" banner over a
/// dimmed [OrderRatingSection] filled with the scores and comments the shopper
/// submitted for every product, the store (`vendor`) and the courier
/// (`delivery`). Unrated subjects fall back to zero stars and an empty comment.
class OrderRatingView extends StatefulWidget {
  const OrderRatingView({super.key, required this.rating});

  final OrderRatingModel rating;

  @override
  State<OrderRatingView> createState() => _OrderRatingViewState();
}

class _OrderRatingViewState extends State<OrderRatingView> {
  static const double _dimmedOpacity = 0.5;

  late final List<ProductModel> _products = widget.rating.products
      .map(
        (RatedProductModel product) => ProductModel(
          name: product.name,
          images: product.imageUrl == null ? null : <String>[product.imageUrl!],
        ),
      )
      .toList();

  late final List<int> _productRatings = widget.rating.products
      .map((RatedProductModel product) => product.rating?.rate ?? 0)
      .toList();

  late final List<TextEditingController> _productComments = widget
      .rating
      .products
      .map(
        (RatedProductModel product) =>
            TextEditingController(text: product.rating?.comment ?? ''),
      )
      .toList();

  late final TextEditingController _storeComment = TextEditingController(
    text: widget.rating.vendor.rating?.comment ?? '',
  );
  late final TextEditingController _courierComment = TextEditingController(
    text: widget.rating.delivery.rating?.comment ?? '',
  );

  @override
  void dispose() {
    for (final TextEditingController controller in _productComments) {
      controller.dispose();
    }
    _storeComment.dispose();
    _courierComment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.green500.withValues(alpha: 0.1),
            borderRadius: AppBorderRadius.brCircular12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Assets.media.images.svg.tickCircle.svg(
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(colors.green500, BlendMode.srcIn),
              ),
              Text(
                '${LangKeys.thanksForRatingKey.tr()}!',
                style: AppTextStyles.style14SemiBold.copyWith(
                  color: colors.green500,
                ),
              ),
            ],
          ),
        ),
        IgnorePointer(
          child: Opacity(
            opacity: _dimmedOpacity,
            child: OrderRatingSection(
              products: _products,
              productRatings: _productRatings,
              productComments: _productComments,
              courierRating: widget.rating.delivery.rating?.rate ?? 0,
              storeRating: widget.rating.vendor.rating?.rate ?? 0,
              courierComment: _courierComment,
              storeComment: _storeComment,
              commentHint: '${LangKeys.writeYourCommentHereKey.tr()}...',
              readOnly: true,
            ),
          ),
        ),
      ],
    );
  }
}
