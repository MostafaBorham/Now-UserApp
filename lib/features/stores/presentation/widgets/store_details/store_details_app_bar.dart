import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';

class StoreDetailsAppBar extends StatelessWidget {
  const StoreDetailsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Navigator.canPop(context)
                ? InkWell(
              onTap: () => Navigator.pop(context),
              child: CircleAvatar(
                backgroundColor: colors.onPrimary,
                radius: 25,
                child: Center(
                  child: Assets.media.images.svg.appBackArrow
                      .svg(fit: BoxFit.contain, width: 25),
                ),
              ),
            )
                : const SizedBox(),
          ),
        ),
        Expanded(
          flex: 2,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              LangKeys.storesKey.tr(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.style24SemiBold.copyWith(
                color: colors.onSecondary,
                // fontSize: screenSize.width*0.06
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: CircleAvatar(
                  backgroundColor: colors.onPrimary,
                  radius: 25,
                  child: Center(
                    child: Assets.media.images.svg.shoppingCartIcon
                        .svg(
                      fit: BoxFit.contain,
                      width: 25,
                      colorFilter: ColorFilter.mode(
                        colors.onSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
