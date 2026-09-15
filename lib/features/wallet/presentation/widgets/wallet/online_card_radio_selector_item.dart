import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/enums/online_card_types.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/params/online_card_params.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class OnlineCardRadioSelectorItem extends StatelessWidget {
  const OnlineCardRadioSelectorItem({
    super.key,
    required this.cardItem,
    required this.isSelected,
  });

  final OnlineCardParams cardItem;
  final bool isSelected;

  /// How far an unusable (expired / non-card) row is faded. It stays legible —
  /// the customer still needs to recognise the card in order to replace it — but
  /// reads as unavailable, and the "expired" label says why.
  static const double _unusableOpacity = 0.45;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isUsable = cardItem.isUsable;

    return Material(
      color: Colors.transparent,
      child: Opacity(
        opacity: isUsable ? 1 : _unusableOpacity,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: colors.neutral500.withValues(alpha: 0.1),
            borderRadius: AppBorderRadius.brCircular12,
          ),
          child: IntrinsicHeight(
            child: Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isSelected ? colors.primary500Main : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? colors.primaryContainer.withValues(alpha: 0.5)
                          : colors.neutral500,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                10.wSpace,
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cardItem.cardHolder,
                        style: AppTextStyles.style16Medium.copyWith(
                          color: colors.black,
                        ),
                      ),
                      Row(
                        spacing: 8,
                        children: [
                          Flexible(
                            child: Text(
                              cardItem.cardNumber,
                              maxLines: 1,
                              style: AppTextStyles.style14Regular.copyWith(
                                color: colors.neutral500,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          // Says why the row is dimmed and untappable. The card
                          // is kept on screen rather than hidden so the customer
                          // can tell which one to replace.
                          if (!isUsable)
                            Text(
                              LangKeys.expiredKey.tr(),
                              maxLines: 1,
                              style: AppTextStyles.style12Medium.copyWith(
                                color: colors.error,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: switch (cardItem.cardType) {
                    OnlineCardTypes.visa => Assets.media.images.svg.visaLogo.svg(
                        width: 25,
                      ),
                    OnlineCardTypes.master =>
                      Assets.media.images.svg.masterLogo.svg(
                        width: 25,
                      ),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
