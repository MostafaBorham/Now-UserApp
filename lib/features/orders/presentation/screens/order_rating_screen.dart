import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/order_rating/order_rating_product_row.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/order_rating/order_rating_subject_section.dart';

/// Lets the shopper rate a delivered [order]: a star rating plus an optional
/// comment for every line item, the courier and the store. The committed
/// ratings and the comment controllers are held here; the star rows and comment
/// boxes are stateless and report back through callbacks.
class OrderRatingScreen extends StatefulWidget {
  const OrderRatingScreen({super.key, required this.order});

  final OrderModel order;

  @override
  State<OrderRatingScreen> createState() => _OrderRatingScreenState();
}

class _OrderRatingScreenState extends State<OrderRatingScreen> {
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

  void _onSubmit() {
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final String commentHint = '${LangKeys.writeYourCommentHereKey.tr()}...';

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
                      if (_products.isNotEmpty)
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
                                style: AppTextStyles.style14Bold.copyWith(
                                  color: colors.black,
                                ),
                              ),
                              for (int i = 0; i < _products.length; i++) ...[
                                if (i > 0)
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: colors.neutral300,
                                  ),
                                OrderRatingProductRow(
                                  name: context.getLocalizedApiText(
                                    _products[i].name,
                                  ),
                                  imageUrl:
                                      _products[i].images?.firstOrNull ?? '',
                                  rating: _productRatings[i],
                                  commentHint: commentHint,
                                  commentController: _productComments[i],
                                  onRatingSelected: (int value) => setState(
                                    () => _productRatings[i] = value,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      OrderRatingSubjectSection(
                        title: LangKeys.deliveryAgentKey.tr(),
                        rating: _courierRating,
                        commentHint: commentHint,
                        commentController: _courierComment,
                        onRatingSelected: (int value) =>
                            setState(() => _courierRating = value),
                      ),
                      OrderRatingSubjectSection(
                        title: LangKeys.storeKey.tr(),
                        rating: _storeRating,
                        commentHint: commentHint,
                        commentController: _storeComment,
                        onRatingSelected: (int value) =>
                            setState(() => _storeRating = value),
                      ),
                    ],
                  ),
                ),
              ),
              PrimaryAppButton(
                title: LangKeys.submitRatingKey.tr(),
                onTap: _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
