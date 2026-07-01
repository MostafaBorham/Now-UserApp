import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';

class AppSearchField extends ConsumerWidget {
  const AppSearchField({super.key, this.hintText, this.reverseSearchIcon = false});
  final String? hintText;
  final bool? reverseSearchIcon;
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return AspectRatio(
      aspectRatio: 7.5,
      child: LayoutBuilder(
        builder: (context,con) {
          return Container(
            decoration: BoxDecoration(
              color: colors.onPrimary,
              borderRadius: AppBorderRadius.brCircular30,
              boxShadow: AppBoxShadows.blackBottomShadow1,
            ),
            child: Center(
              child: TextField(
                decoration: InputDecoration(
                  hintText: hintText?? LangKeys.searchNowKey.tr(),
                  hintStyle: AppTextStyles.style16Regular.copyWith(
                    color:colors.onPrimaryFixed,
                    fontSize: con.maxWidth*0.05
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 16),
                    child: ReverseWidget(
                      applyReverse: reverseSearchIcon,
                      child: Assets.media.images.svg.searchIcon.svg(
                      ),
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(
                    maxHeight: 25.w,
                    minWidth: 25.w,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
