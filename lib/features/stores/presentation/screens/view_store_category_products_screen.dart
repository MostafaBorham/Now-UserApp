import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_model_provider.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_products_search_provider.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_products_view.dart';

class ViewStoreCategoryProductsScreen extends ConsumerWidget {
  const ViewStoreCategoryProductsScreen({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: <Override>[
        categoryProvider.overrideWithValue(category),
      ],
      child: Scaffold(
        body: AppWavedView(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: <Widget>[
              PrimarySearchField(
                isAnimated: false,
                onSearch: (String query) => ref
                    .read(categoryProductsSearchProvider.notifier)
                    .state = query,
              ),
              const Expanded(
                child: CategoryProductsView(sortType: StoresSortType.all),
              ),
            ],
          ),
          appBarTitle: context.getLocalizedApiText(category.name),
          canPop: context.canPop(),
        ),
      ),
    );
  }
}
