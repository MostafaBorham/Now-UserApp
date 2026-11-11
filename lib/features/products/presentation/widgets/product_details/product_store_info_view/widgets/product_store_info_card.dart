import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';

class ProductStoreInfoCard extends StatelessWidget {
  const ProductStoreInfoCard({super.key, required this.store, this.onTap});

  final StoreModel store;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final BorderRadius borderRadius = BorderRadius.circular(16);

    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: borderRadius,
          border: Border.all(color: colors.primary500Main),
          boxShadow: [
            BoxShadow(
              color: colors.black.withValues(alpha: 0.15),
              blurRadius: 0.5,
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              spacing: 8,
              children: [
                CircularBrandLogo(
                  radius: 18,
                  logoUrl: store.logoUrl,
                  backgroundColor: colors.neutral100,
                  borderSide: BorderSide(color: colors.neutral200),
                ),
                Expanded(
                  child: Text(
                    context.getLocalizedApiText(store.name),
                    style: AppTextStyles.style13Bold.copyWith(
                      color: colors.neutral1200,
                      height: 1.5,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
                if (store.rating != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.tertiaryFixed,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: AppRateWidget(
                      starColor: colors.surface,
                      rateColor: colors.tertiaryContainer,
                      rateRatio: '${formatDouble(store.rating)}',
                      size: 12,
                      starSize: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
