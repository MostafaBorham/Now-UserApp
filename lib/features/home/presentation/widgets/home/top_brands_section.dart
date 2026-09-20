import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/circular_brand_item.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/show_more_items_header.dart';

class TopBrandsSection extends StatelessWidget {
  const TopBrandsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 15,
      children: [
        ShowMoreItemsHeader(headerTitle: LangKeys.topBrandsKey.tr(),onMore: () => context.pushNamed(AppRoutes.topBrandsScreen),),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // A mock item with no store behind it — there is no id to open
            // store details with, so it doesn't navigate.
            itemBuilder: (context, index) => CircularBrandItem(),
            separatorBuilder: (context, index) => 12.wSpace,
            itemCount: 6,
          ),
        ),
      ],
    );
  }
}
