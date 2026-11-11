import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/products/presentation/controllers/product_reviews_controller.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_reviews/reviews_filter_view/reviews_filter_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_reviews/reviews_list/reviews_list.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_reviews/reviews_rating_summary/reviews_rating_summary.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_reviews/reviews_top_bar/reviews_top_bar.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_reviews/write_review_panel/write_review_panel.dart';

class ProductReviewsScreen extends StatefulWidget {
  const ProductReviewsScreen({super.key});

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen>
    with TickerProviderStateMixin {
  late final ProductReviewsController _controller = ProductReviewsController(
    vsync: this,
    view: View.of(context),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ReviewsTopBar(
            onFilterTap: () => ReviewsFilterView.show(
              context,
              initialSortOption: _controller.sortOption,
              onApply: _controller.applySortOption,
            ),
          ),
          SizeTransition(
            sizeFactor: _controller.summaryVisibility,
            alignment: Alignment.bottomCenter,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: ReviewsRatingSummary(),
            ),
          ),
          Expanded(
            child: NotificationListener<UserScrollNotification>(
              onNotification: _controller.onUserScroll,
              child: const ReviewsList(),
            ),
          ),
          SizeTransition(
            sizeFactor: _controller.visibility,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: WriteReviewPanel(
                rating: _controller.rating,
                commentController: _controller.commentController,
                onRatingSelected: _controller.selectRating,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
