import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/view_store_category_products_screen/store_category_products_view.dart';

class ViewStoreCategoryProductsScreen extends StatelessWidget {
  const ViewStoreCategoryProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppWavedScaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            AppSearchField(hintText: LangKeys.searchForAProductKey.tr(),),
            // Text(LangKeys.filtersKey.tr(),style: AppTextStyles.style14SemiBold.copyWith(
            //     color: colors.onSecondary
            // ),),
            Expanded(
              child: StoreCategoryProductsView(),
            ),
          ],
        ),
        appBarTitle: LangKeys.offersKey.tr(),
        canPop: Navigator.canPop(context),
      ),
    );
  }
}
