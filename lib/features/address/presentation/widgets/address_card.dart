import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

import '../../../settings/app_colors.dart';

/// A single saved address (Home, Office, …) rendered as a selectable card.
///
/// The default card is filled with a soft green gradient, framed by a thin
/// green border and shows a filled green radio; every other card is a flat
/// grey card with a hollow radio.
///
/// Tapping anywhere on the card triggers [onSelect]; the pen icon in the
/// top-right corner triggers [onEdit].
class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.title,
    required this.address,
    this.isDefault = false,
    this.onSelect,
    this.onEdit,
  });

  /// Short label for the address, e.g. "Home" or "Office".
  final String title;

  /// Full, human-readable address line.
  final String address;

  /// When true this is the selected / default address and is highlighted.
  final bool isDefault;

  /// Called when the card is tapped (selects this address).
  final VoidCallback? onSelect;

  /// Called when the trailing pen icon is tapped.
  final VoidCallback? onEdit;

  static const double _radius = 20;

  /// Width of the leading slot (radio / pin) so the title and the address
  /// line share the same left text column.
  static const double _leadingSlot = 20;
  static const double _leadingGap = 12;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_radius),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          color: isDefault ? null : AppColors.cardBackground,
          gradient: isDefault
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.selectedAddressStart,
                    AppColors.selectedAddressEnd,
                  ],
                )
              : null,
          border: isDefault
              ? Border.all(color: AppColors.selectedAddressBorder)
              : null,
        ),
        child: InkWell(
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1 — radio, title and the edit action.
                Row(
                  children: [
                    _Radio(selected: isDefault),
                    const SizedBox(width: _leadingGap),
                    Expanded(
                      child: Text(
                        isDefault
                            ? '$title ${LangKeys.defaultAddress.tr()}'
                            : title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _EditButton(onTap: onEdit),
                  ],
                ),
                const SizedBox(height: 14),
                // Row 2 — location pin and the address line.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Assets.media.images.svg.pin.svg(
                        width: _leadingSlot,
                        height: _leadingSlot,
                      ),
                    ),
                    const SizedBox(width: _leadingGap),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.3,
                          fontWeight: FontWeight.w400,
                          color: AppColors.addressText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom radio: a filled green dot when [selected], otherwise a hollow ring.
class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AddressCard._leadingSlot,
      height: AddressCard._leadingSlot,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primaryGreen : AppColors.radioUnselected,
          width: selected ? 2 : 1.5,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGreen,
                ),
              ),
            )
          : null,
    );
  }
}

/// Circular, tappable pen icon shown in the top-right corner of a card.
class _EditButton extends StatelessWidget {
  const _EditButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Assets.media.images.svg.edit.svg(width: 22, height: 22),
        ),
      ),
    );
  }
}
