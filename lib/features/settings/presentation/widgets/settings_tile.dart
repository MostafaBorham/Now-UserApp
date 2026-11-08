import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Data model describing a single tappable row inside a [SettingsSection].
class SettingsItem {
  const SettingsItem({
    required this.iconAsset,
    required this.label,
    this.onTap,
    this.iconColor,
    this.isLoading = false,
  });

  /// Path to the SVG icon (from the `assets/svg` folder).
  final String iconAsset;

  /// Text shown next to the icon.
  final String label;

  /// Called when the row is tapped.
  final VoidCallback? onTap;

  /// Tints the icon; `null` draws the SVG in its own colours. Overridden by
  /// the section's colour in a danger section.
  final Color? iconColor;

  /// Swaps the chevron for a spinner and ignores taps (e.g. while logging out).
  final bool isLoading;
}

/// A single settings row: leading icon, label, and a trailing chevron.
///
/// Icons are rendered straight from the provided SVG assets, so they are
/// used as-is (placeholders) and never redrawn in code. When [color] is set
/// (the danger section) the icon, label and chevron all take it.
class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.item, this.color});

  final SettingsItem item;
  final Color? color;

  static const double _iconSize = 22;
  static const double _iconSlot = 24;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color? iconColor = color ?? item.iconColor;
    return InkWell(
      onTap: item.isLoading ? null : item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            SizedBox(
              width: _iconSlot,
              height: _iconSlot,
              child: Center(
                child: SvgPicture.asset(
                  item.iconAsset,
                  width: _iconSize,
                  height: _iconSize,
                  colorFilter: iconColor == null
                      ? null
                      : ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color ?? colors.tertiaryContainer,
                ),
              ),
            ),
            if (item.isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color ?? colors.neutral500,
                ),
              )
            else if (item.onTap != null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: color ?? colors.neutral500,
              )
            else
              const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
