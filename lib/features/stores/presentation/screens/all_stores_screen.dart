import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/app_filter_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/categories/categories_product_tab_view.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/categories/categories_store_tab_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/app_tab_bar.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/all_stores/stores_list_view.dart';

class AllStoresScreen extends StatelessWidget {
  const AllStoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: AppWavedScaffold(
        body: Column(
          spacing: 16,
          children: [
            AppSearchField(hintText: LangKeys.searchForAStoreKey.tr()),
            Expanded(
              child: CustomButtonTabBar(
                filterWidget: AppFilterIcon(),
                tabs: [LangKeys.allKey.tr(),...['Devices','Shoes','Cloths']],
                views: [StoresListView(),StoresListView(),StoresListView(),StoresListView(),],
                selectedTabColor: colors.onTertiaryFixed,
                unSelectedTabColor: colors.onSurface.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
        appBarTitle: 'All Stores',
        canPop: Navigator.canPop(context),
      ),
    );
  }
}
