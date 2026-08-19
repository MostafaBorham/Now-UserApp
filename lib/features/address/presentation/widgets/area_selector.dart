import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Grey "Area" summary row pinned to the top of the Address Details form.
///
/// Shows a location pin, the small "Area" label above the selected [value],
/// and a green "Change" action on the trailing edge.
class AreaSelector extends StatelessWidget {
  const AreaSelector({super.key, required this.value, this.onChange});

  /// The selected area, e.g. "Downtown - Tahrir".
  final String value;

  /// Called when the trailing "Change" action is tapped.
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.onPrimaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // White-stroked asset recolored grey so it reads on the grey pill.
          Assets.media.images.svg.addressCuttedGrey.svg(
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(
              context.colors.neutral500,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LangKeys.area.tr(),
                  style: AppTextStyles.style12Regular.copyWith(
                    color: context.colors.neutral500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.style14Regular.copyWith(
                    color: context.colors.tertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onChange,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Text(
                LangKeys.change.tr(),
                style: AppTextStyles.style14SemiBold.copyWith(
                  color: context.colors.primary500Main,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
