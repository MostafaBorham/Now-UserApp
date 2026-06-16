import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/widgets/home/best_nearby_stores_list_item.dart';
import 'package:nowdelivery_user_app/view/widgets/home/circular_brand_logo.dart';

import '../../responsive/spacing_extension.dart';
import '../../styles/text_styles.dart';

class BestNearbyStoresSection extends StatelessWidget {
  const BestNearbyStoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          AutoSizeText('Top Nearby Stores',style: AppTextStyles.style20SemiBold.copyWith(
              color: colors.onTertiaryFixed
          ),),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return BestNearbyStoresListItem();
                return Container(
                  width: 50,
                  color: Colors.red,
                );

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
