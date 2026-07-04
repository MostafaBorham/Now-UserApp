import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/product_item.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/features/categories/categories_interface.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_item_card1.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    // Dummy placeholder data — replaced with real data later.
    final List<String> recentSearches = <String>[
      'Milk',
      'Vegetables',
      'Meat',
      'Fish',
    ];
    final List<String> bestCategories = <String>[
      'Offers',
      'Beauty',
      'Fashion',
      'Grocery',
    ];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: AppWavedScaffold(
          appBarTitle: LangKeys.searchKey.tr(),
          canPop: Navigator.canPop(context),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: <Widget>[
              AppSearchField(
                autofocus: true,
                enableRecentKeywords: true,
                recentKeywords: recentSearches,
                onRecentSelect: (String term) {},
                onRecentRemove: (String term) {},
                onRecentClear: () {},
              ),
              AspectRatio(
                aspectRatio: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          LangKeys.bestCategoriesKey.tr(),
                          style: AppTextStyles.style18SemiBold.copyWith(
                            color: colors.onSecondary,
                            fontSize: screenWidth*0.05
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            LangKeys.seeAllKey.tr(),
                            style: AppTextStyles.style14Medium.copyWith(
                              color: colors.primary,
                                fontSize: screenWidth*0.035
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => AspectRatio(
                          aspectRatio: 0.8,
                          child: CategoryCard(
                            category: CategoryModel(
                              id: 1,
                              name: 'Beauty',
                              imageUrl:
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7in6v147mMSnkxkYcpf0X3UvHmk7HS7bUKWIrG-iqAg&s=10',
                              discountPercentage: 50,
                            ),
                          ),
                        ),
                        separatorBuilder: (context, index) => 10.wSpace,
                        itemCount: 5,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          LangKeys.mostRequestedKey.tr(),
                          style: AppTextStyles.style18SemiBold.copyWith(
                            color: colors.onSecondary,
                              fontSize: screenWidth*0.05
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            LangKeys.seeAllKey.tr(),
                            style: AppTextStyles.style14Medium.copyWith(
                              color: colors.primary,
                                fontSize: screenWidth*0.035
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: 6,
                        itemBuilder: (BuildContext context, int index) =>
                            ProductItemCard1(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
