import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/common/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/common/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/store_item.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/text_fields/app_search_field.dart';

class FavouriteStoreTabView extends StatelessWidget {
  const FavouriteStoreTabView({super.key});
  final bool isStoresEmpty = false;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      spacing: 16,
      children: [
        AppSearchField(hintText: LangKeys.searchForAStoreKey.tr(),),
        Expanded(
          child: isStoresEmpty? NoItemsWidget() : CustomButtonTabBar(
            filterWidget: CircleAvatar(
              backgroundColor: colors.tertiary.withValues(alpha: 0.3),
              radius: 20.r,
              child: Assets.media.images.svg.filterIcon.svg(width: 20.w),
            ),
            tabs: [LangKeys.allKey.tr(), LangKeys.menKey.tr()],
            views: ['', '']
                .map(
                  (e) => ListView.separated(
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) => AspectRatio(
                        aspectRatio: 2,
                        child: StoreItem()),
                    separatorBuilder: (context, index) => 20.hSpace,
                    itemCount: 3,
                  ),
            )
                .toList(),
            selectedLabelColor: colors.onPrimary,
            selectedTabColor: colors.tertiaryContainer,
            unSelectedTabColor: colors.primaryFixed,
          ),
        ),
      ],
    );
  }
}