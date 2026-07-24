import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/view_store_category_products/store_category_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/view_store_category_products/store_id_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/view_store_category_products_screen/store_category_products_view.dart';

class ViewStoreCategoryProductsScreen extends StatelessWidget {
  const ViewStoreCategoryProductsScreen({
    super.key,
    required this.storeId,
    required this.category,
  });
  final int storeId;
  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        storeCategoryProvider.overrideWithValue(category),
        storeIdProvider.overrideWithValue(storeId),
      ],
      child: Scaffold(
        body: AppWavedView(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              AppSearchField(hintText: LangKeys.searchForAProductKey.tr()),
              // Text(LangKeys.filtersKey.tr(),style: AppTextStyles.style14SemiBold.copyWith(
              //     color: colors.onSecondary
              // ),),
              Expanded(child: StoreCategoryProductsView()),
            ],
          ),
          appBarTitle: category.name ?? LangKeys.offersKey.tr(),
          canPop: context.canPop(),
        ),
      ),
    );
  }
}
