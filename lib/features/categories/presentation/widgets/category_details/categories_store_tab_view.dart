import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_stores_search_provider.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_stores_view.dart';

class CategoriesStoreTabView extends ConsumerStatefulWidget {
  const CategoriesStoreTabView({super.key});

  @override
  ConsumerState<CategoriesStoreTabView> createState() =>
      _CategoriesStoreTabViewState();
}

class _CategoriesStoreTabViewState
    extends ConsumerState<CategoriesStoreTabView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [

        PrimarySearchField(
          isAnimated: false,
          onSearch: (String query) =>
              ref.read(categoryStoresSearchProvider.notifier).state = query,
        ),
        const Expanded(child: CategoryStoresView()),


      ],
    );
  }
}
