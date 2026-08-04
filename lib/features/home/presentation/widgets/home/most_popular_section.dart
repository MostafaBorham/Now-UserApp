import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/show_more_items_header.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/most_popular_item.dart';


class MostPopularSection extends StatelessWidget {
  const MostPopularSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.tertiary.withValues(alpha: 0.4), colors.onPrimary],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
      ),
      child: Column(
        spacing: 10,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: ShowMoreItemsHeader(headerTitle: LangKeys.mostPopularKey.tr(),onMore: () => context.pushNamed(AppRoutes.mostPopularScreen),),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsetsDirectional.only(start: 15),
              itemBuilder: (context, index) {
                return InkWell(
                    onTap: () => context.pushNamed(AppRoutes.productDetailsScreen),
                    child: MostPopularItem());
              },
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) {
                return 10.wSpace;
              },
              itemCount: 5,
            ),
          ),
        ],
      ),
    );
  }
}
