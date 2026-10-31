import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';

class LogoTitleExpansionHeader extends StatelessWidget {
  const LogoTitleExpansionHeader({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    this.storeName,
    this.logoUrl,
    this.badge,
    this.onStoreTap,
  });

  final bool isExpanded;
  final ValueChanged<bool> onToggle;

  /// Localized store name as an API translation map. Falls back to a
  /// placeholder title when null.
  final Map<String, dynamic>? storeName;

  /// Store logo url. Falls back to a placeholder logo when null.
  final String? logoUrl;

  /// Shown after the title, e.g. the store's status pill.
  final Widget? badge;

  /// Fired by a tap on the logo or name, which then no longer toggles; the
  /// rest of the row, arrow included, still does. `null` leaves the whole row
  /// toggling.
  final VoidCallback? onStoreTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final String title = storeName == null
        ? 'Banda Store'
        : context.getLocalizedApiText(storeName);
    return InkWell(
      onTap: () => onToggle(!isExpanded),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                Flexible(
                  // An InkWell with no onTap claims no taps, so a null
                  // onStoreTap falls through to the row's toggle.
                  child: InkWell(
                    onTap: onStoreTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 12,
                      children: [
                        CircularBrandLogo(
                          radius: 24,
                          elevation: 1,
                          backgroundColor: colors.onTertiaryContainer,
                          logoUrl: logoUrl,
                        ),
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.style16Medium.copyWith(
                              color: colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ?badge,
              ],
            ),
          ),
          Icon(
            isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 24,
            color: colors.neutral500.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}
