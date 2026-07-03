import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/product_item.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

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
          body: SingleChildScrollView(
            child: Column(
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

                // Best categories
                Column(
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
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            LangKeys.seeAllKey.tr(),
                            style: AppTextStyles.style14Medium.copyWith(
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        itemCount: bestCategories.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            SizedBox(width: 12),
                        itemBuilder: (BuildContext context, int index) => SizedBox(
                          width: 100,
                          child: Column(
                            spacing: 6,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  alignment: AlignmentDirectional.topStart,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: AppBorderRadius.brCircular16,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: <Color>[
                                        colors.surfaceContainerHighest,
                                        colors.surface,
                                      ],
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.errorContainer,
                                      borderRadius: AppBorderRadius.brCircular6,
                                    ),
                                    child: Text(
                                      index == 0
                                          ? '${LangKeys.upToKey.tr()} 50% ${LangKeys.discountKey.tr()}'
                                          : '50% ${LangKeys.discountKey.tr()}',
                                      style: AppTextStyles.style8SemiBold
                                          .copyWith(color: colors.onPrimary),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                bestCategories[index],
                                maxLines: 1,
                                style: AppTextStyles.style14Medium.copyWith(
                                  color: colors.onSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Most requested
                Column(
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
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            LangKeys.seeAllKey.tr(),
                            style: AppTextStyles.style14Medium.copyWith(
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 6,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.6,
                      ),
                      itemBuilder: (BuildContext context, int index) =>
                          const ProductItem(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
