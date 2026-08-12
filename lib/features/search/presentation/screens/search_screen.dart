import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/categories/category_card.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cards/product_item_card1.dart';
import 'package:nowdelivery_user_app/features/search/viewmodel/recent_search_vm.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    // Recent search keywords (loaded on first watch by the provider).
    final RecentSearchViewModel recentVm = ref.read(
      recentSearchProvider.notifier,
    );
    final List<String> recentSearches =
        ref.watch(recentSearchProvider).valueOrNull ?? const <String>[];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppWavedView(
        appBarTitle: LangKeys.searchKey.tr(),
        canPop: context.canPop(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: <Widget>[
            AppSearchField(
              autofocus: true,
              navigateToSearchOnTap: false,
              enableRecentKeywords: true,
              recentKeywords: recentSearches,
              // Live-filter recents as the user types (req 5).
              onChanged: recentVm.filterRecentSearch,
              // Submit a new keyword to the database, then unfocus (req 6).
              onSubmitted: recentVm.addSearchKey,
              // Remove a single recent keyword (req 2).
              onRecentRemove: recentVm.removeSearchKey,
              // Clear all recent keywords (req 3).
              onRecentClear: recentVm.clearAll,
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
                          fontSize: screenWidth * 0.05,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          context.pushNamed(AppRoutes.categoriesScreen);
                        },
                        child: Text(
                          LangKeys.seeAllKey.tr(),
                          style: AppTextStyles.style14Medium.copyWith(
                            color: colors.primary,
                            fontSize: screenWidth * 0.035,
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
                            name: {
                              "ar": "الإلكترونيات",
                              "en": "Electronics"
                            },
                            slug: '',
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
                        LangKeys.mostPopularKey.tr(),
                        style: AppTextStyles.style18SemiBold.copyWith(
                          color: colors.onSecondary,
                          fontSize: screenWidth * 0.05,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          context.pushNamed(AppRoutes.mostPopularScreen);
                        },
                        child: Text(
                          LangKeys.seeAllKey.tr(),
                          style: AppTextStyles.style14Medium.copyWith(
                            color: colors.primary,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: GridView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
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
    );
  }
}
