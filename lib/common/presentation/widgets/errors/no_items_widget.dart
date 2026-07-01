import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';

class NoItemsWidget extends StatelessWidget {
  const NoItemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        spacing: 20,
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.media.images.svg.noItemsIcon.svg(fit: BoxFit.contain,width: MediaQuery.sizeOf(context).width*0.5),
          Text(LangKeys.noItemsYetKey.tr(),style: AppTextStyles.style24SemiBold.copyWith(
            color: colors.onSecondary,
            fontSize: MediaQuery.sizeOf(context).width*0.04
          ),)
        ],
      ),
    );
  }
}
