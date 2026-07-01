import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../common/localization/lang_keys.dart';
import '../../../../../view/styles/text_styles.dart';
import 'circular_brand_logo.dart';

class CircularBrandItem extends StatelessWidget {
  const CircularBrandItem({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Column(
      spacing: 10,
      children: [
        CircularBrandLogo(radius: 50.w,logoUrl: 'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',),
        AutoSizeText('Panda',style: AppTextStyles.style16SemiBold.copyWith(
          color: colors.onSecondary,
        ),),
      ],
    );
  }
}
