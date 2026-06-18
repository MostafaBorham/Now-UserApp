import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/common/models/category_model.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/categories/category_card.dart';
import 'package:nowdelivery_user_app/view/widgets/categories/product_tab_view.dart';
import 'package:nowdelivery_user_app/view/widgets/categories/store_tab_view.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/app_search_field.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/reverse_widget.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/tab_bars/custom_tab_bar_with_fixed_widget.dart';

class CategoryDetailsScreen extends StatelessWidget {
  const CategoryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.onPrimary,
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 70),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.onSecondaryFixed,
              colors.onPrimary,
              colors.onPrimary,
            ],
          ),
        ),
        child: Column(
          spacing: 20,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      backgroundColor: colors.onPrimary,
                      radius: 20.r,
                      child: ReverseWidget(
                        child: Assets.media.images.svg.arrowBrokenIcon.svg(),
                      ),
                    ),
                  ),
                  AutoSizeText(
                    'Offers',
                    style: AppTextStyles.style24SemiBold.copyWith(
                      color: colors.onSecondary,
                    ),
                  ),
                  20.wSpace,
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Assets.media.images.svg.whiteWaveBackground.svg(
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 50.0,
                    ).copyWith(bottom: 0),
                    child: CustomTabBarWithFixedWidget(
                      tabs: ['Products', 'Stores'],
                      views: [
                        ProductTabView(),
                        StoreTabView(),
                      ],
                      selectedTabColor: colors.primary,
                      fixedWidget: AppSearchField(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
