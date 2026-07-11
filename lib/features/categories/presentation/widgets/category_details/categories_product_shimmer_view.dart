import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_item_card2.dart';

class CategoriesProductShimmerView extends StatelessWidget {
  const CategoriesProductShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: EdgeInsets.zero,
            indicator: const BoxDecoration(),
            dividerHeight: 0,
            splashFactory: NoSplash.splashFactory,
            dividerColor: Colors.transparent,
            overlayColor: WidgetStateProperty.resolveWith(
                  (states) => Colors.transparent,
            ),
            labelPadding: EdgeInsets.symmetric(horizontal: 6),
            tabs: List.generate(4, (index) {

              return Tab(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: AppBorderRadius.brCircular20,
                  ),
                  child: Text(
                    'All',
                    maxLines: 1,
                  ),
                ),
              );
            }),
          ),
          Expanded(
            child: TabBarView(
              children: List.generate(4, (index) {

                return GridView.builder(
                  padding: EdgeInsets.all(4),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: 6,
                  itemBuilder:
                      (BuildContext context, int index) =>
                      ProductItemCard2(),
                );
              })),
          )
        ],
      ),
    );
  }
}
