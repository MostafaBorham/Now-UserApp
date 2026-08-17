import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/app_filter_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_item.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';

class HomeAllStoresSectionView extends StatelessWidget {
  const HomeAllStoresSectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      spacing: 16,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'جميع المتاجر',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.black,
              ),
            ),
            Text(
              'عرض الكل',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.black,
              ),
            ),
          ],
        ),
        Expanded(
          child: CustomButtonTabBar(
            filterWidget: AppFilterIcon(),
            tabs: [
              LangKeys.allKey.tr(),
              ...['الأجهزة', 'الأحذية', 'الملابس'],
            ],
            views: [
              HomeStoresListView(),
              HomeStoresListView(),
              HomeStoresListView(),
              HomeStoresListView(),
            ],
            selectedTabColor: colors.primary500Main,
            unSelectedTabColor: colors.neutral500.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}

class HomeStoresListView extends StatelessWidget {
  const HomeStoresListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) =>
      const AspectRatio(aspectRatio: 2, child: StoreItem()),
      separatorBuilder: (context, index) => 15.hSpace,
      itemCount: 5,
    );
  }
}
