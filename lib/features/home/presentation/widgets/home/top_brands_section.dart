import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/route/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/circular_brand_item.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/show_more_items_header.dart';

class TopBrandsSection extends StatelessWidget {
  const TopBrandsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Column(
      spacing: 15,
      children: [
        ShowMoreItemsHeader(headerTitle: LangKeys.topBrandsKey.tr(),onMore: () => Navigator.pushNamed(context, AppRoutes.topBrandsScreen),),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.storeDetailsScreen),
                child: CircularBrandItem()),
            separatorBuilder: (context, index) => 12.wSpace,
            itemCount: 6,
          ),
        ),
      ],
    );
  }
}
