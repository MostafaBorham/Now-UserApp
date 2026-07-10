import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

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
            child: context.canPop()
                ? InkWell(
              onTap: () => context.pop(),
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
                onTap: () => context.pop(),
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
