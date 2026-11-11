import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

class MostLikelyProductsSection extends StatelessWidget {
  const MostLikelyProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              LangKeys.youMayLikeItKey.tr(),
              style: AppTextStyles.style16Bold.copyWith(
                color: context.colors.black,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(
            height: constraints.maxWidth * 245 / 390,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(width: 4),
              itemBuilder: (context, index) => ProductItem3View(onTap: () {}),
            ),
          ),
        ],
      ),
    );
  }
}
