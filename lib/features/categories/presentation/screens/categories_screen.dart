import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/constants/app_keys.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/categories/category_card.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/categories/category_card_shimmer.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  static const SliverGridDelegateWithFixedCrossAxisCount _gridDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        mainAxisExtent: 220,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CategoryModel>> categoriesState = ref.watch(
      getAppCategoriesProvider,
    );

    return Scaffold(
      body: AppWavedView(
        appBarTitle: LangKeys.categoriesTitleKey.tr(),
        canPop: context.canPop(),
        body: SafeArea(
          child: categoriesState.when(
            loading: () => AppShimmer(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: _gridDelegate,
                itemCount: 8,
                itemBuilder: (_, _) => const CategoryCardShimmer(),
              ),
            ),
            error: (Object error, StackTrace stackTrace) =>
                ServerConnectionErrorWidget(
                  message: error.toString(),
                  onRetry: () => ref
                      .read(getAppCategoriesProvider.notifier)
                      .getAppCategories(),
                ),
            data: (List<CategoryModel> categories) => categories.isEmpty
                ? const NoItemsWidget()
                : GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: _gridDelegate,
                    itemCount: categories.length,
                    itemBuilder: (BuildContext context, int index) =>
                        CategoryCard(
                          category: categories[index],
                          onTap: () {
                            context.pushNamed(
                              AppRoutes.categoryDetailsScreen,
                              extra: categories[index],
                            );
                          },
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}
