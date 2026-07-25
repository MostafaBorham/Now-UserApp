import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

import '../../../settings/app_colors.dart';

/// Grey "Area" summary row pinned to the top of the Address Details form.
///
/// Shows a location pin, the small "Area" label above the selected [value],
/// and a green "Change" action on the trailing edge.
class AreaSelector extends StatelessWidget {
  const AreaSelector({
    super.key,
    required this.value,
    this.label = 'Area',
    this.onChange,
  });

  /// The selected area, e.g. "Downtown - Tahrir".
  final String value;

  /// Caption shown above the value.
  final String label;

  /// Called when the trailing "Change" action is tapped.
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // White-stroked asset recolored grey so it reads on the grey pill.
          Assets.media.images.svg.addressCuttedGrey.svg(
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              AppColors.hintText,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LangKeys.area.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.fieldLabel,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
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
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
