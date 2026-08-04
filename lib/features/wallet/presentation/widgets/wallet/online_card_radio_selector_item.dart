import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/enums/online_card_types.dart';
import 'package:nowdelivery_user_app/core/params/online_card_params.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class OnlineCardRadioSelectorItem extends StatelessWidget {
  const OnlineCardRadioSelectorItem({
    super.key,
    required this.cardItem, required this.isSelected,
  });

  final OnlineCardParams cardItem;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Material(
      color: Colors.transparent,
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
                  color: isSelected ? colors.primary500Main : Colors.transparent,
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
                    Text(
                      cardItem.cardNumber,
                      maxLines: 1,
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.neutral500,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                  OnlineCardTypes.master => Assets.media.images.svg.masterLogo.svg(
                    width: 25,
                  ),
                },
              ),
            ],
          ),
        )
      ),
    );
  }
}