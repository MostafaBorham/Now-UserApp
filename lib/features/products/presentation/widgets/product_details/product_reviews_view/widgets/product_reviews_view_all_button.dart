import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';

class ProductReviewsViewAllButton extends StatelessWidget {
  const ProductReviewsViewAllButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          Text(
            LangKeys.viewAllReviewsKey.tr(),
            style: AppTextStyles.style12Bold.copyWith(
              color: colors.primary500Main,
              height: 2,
            ),
          ),
          ReverseWidget(
            child: Assets.media.images.svg.seeAllArrowIcon.svg(
              width: 10,
              height: 10,
              colorFilter: ColorFilter.mode(
                colors.primary500Main,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
