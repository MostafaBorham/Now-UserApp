import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/common/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/circular_brand_item.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/show_more_items_header.dart';

class TopBrandsSection extends StatelessWidget {
  const TopBrandsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Column(
      spacing: 15,
      children: [
        ShowMoreItemsHeader(headerTitle: LangKeys.topBrandsKey.tr(),),
        SizedBox(
          height: 150.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => CircularBrandItem(),
            separatorBuilder: (context, index) => 12.wSpace,
            itemCount: 6,
          ),
        ),
      ],
    );
  }
}
