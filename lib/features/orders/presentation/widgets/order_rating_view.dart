import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/order_rating_section.dart';

/// The read-only "already rated" state shown in place of the rate-order button
/// once [OrderModel.hasRated] is set: a "thanks for rating" banner over a dimmed
/// [OrderRatingSection]. There is no stored per-order rating yet, so the section
/// shows fixed sample stars and a sample comment against the order's real
/// product names and images, dimmed and non-interactive.
class OrderRatingView extends StatefulWidget {
  const OrderRatingView({super.key, required this.products});

  final List<ProductModel> products;

  @override
  State<OrderRatingView> createState() => _OrderRatingViewState();
}

class _OrderRatingViewState extends State<OrderRatingView> {
  static const int _sampleRating = 4;
  static const double _dimmedOpacity = 0.5;

  final TextEditingController _sampleComment = TextEditingController(
    text: LangKeys.ratingSampleCommentKey.tr(),
  );

  late final List<int> _productRatings = List<int>.filled(
    widget.products.length,
    _sampleRating,
  );
  late final List<TextEditingController> _productComments =
      List<TextEditingController>.filled(
        widget.products.length,
        _sampleComment,
      );

  @override
  void dispose() {
    _sampleComment.dispose();
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
              products: widget.products,
              productRatings: _productRatings,
              productComments: _productComments,
              courierRating: _sampleRating,
              storeRating: _sampleRating,
              courierComment: _sampleComment,
              storeComment: _sampleComment,
              commentHint: LangKeys.ratingSampleCommentKey.tr(),
              readOnly: true,
            ),
          ),
        ),
      ],
    );
  }
}
