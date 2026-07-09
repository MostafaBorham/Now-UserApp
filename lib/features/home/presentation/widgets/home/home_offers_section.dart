import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/show_more_items_header.dart';
import 'package:nowdelivery_user_app/core/route/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/home_offers_item.dart';

import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class HomeOffersSection extends StatelessWidget {
  const HomeOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: colors.primary
      ),
      child: Column(
        spacing: 10,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: ShowMoreItemsHeader(headerTitle: LangKeys.dontMissTheseOffersKey.tr(),onMore: () => Navigator.pushNamed(context, AppRoutes.offersCannotWaitScreen),),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsetsDirectional.only(start: 15),
              itemBuilder: (context, index) {
                return HomeOffersItem();
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
