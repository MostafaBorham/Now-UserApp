import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class FilterPriceView extends StatefulWidget {
  const FilterPriceView({super.key, this.onChanged});

  static const double minPrice = 0;
  static const double maxPrice = 10000;

  final ValueChanged<RangeValues>? onChanged;

  @override
  State<FilterPriceView> createState() => _FilterPriceViewState();
}

class _FilterPriceViewState extends State<FilterPriceView> {
  RangeValues priceRange = const RangeValues(
    FilterPriceView.minPrice,
    FilterPriceView.maxPrice,
  );
  final TextEditingController maxLimitController = TextEditingController(
    text: FilterPriceView.maxPrice.round().toString(),
  );
  final TextEditingController minLimitController = TextEditingController(
    text: FilterPriceView.minPrice.round().toString(),
  );

  void updateRange(RangeValues values) {
    setState(() => priceRange = values);
    widget.onChanged?.call(values);
  }

  @override
  void dispose() {
    maxLimitController.dispose();
    minLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final OutlineInputBorder limitFieldBorder = OutlineInputBorder(
      borderRadius: AppBorderRadius.brCircular8,
      borderSide: BorderSide(color: colors.neutral300),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          LangKeys.priceKey.tr(),
          style: AppTextStyles.style14SemiBold.copyWith(
            color: colors.neutral1200,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: colors.secondaryFixed,
            inactiveTrackColor: colors.secondary100,
            overlayShape: SliderComponentShape.noOverlay,
            rangeThumbShape: _FilterSliderThumbShape(
              thumbColor: colors.secondaryFixed,
              haloColor: colors.secondaryFixed.withValues(alpha: 0.35),
            ),
          ),
          child: RangeSlider(
            values: priceRange,
            min: FilterPriceView.minPrice,
            max: FilterPriceView.maxPrice,
            onChanged: (values) {
              maxLimitController.text = values.end.round().toString();
              minLimitController.text = values.start.round().toString();
              updateRange(values);
            },
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    LangKeys.maximumLimitKey.tr(),
                    style: AppTextStyles.style14Medium.copyWith(
                      color: colors.neutral1200,
                    ),
                  ),
                  TextFormField(
                    controller: maxLimitController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    style: AppTextStyles.style14Regular.copyWith(
                      color: colors.neutral1200,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: LangKeys.maximumLimitKey.tr(),
                      hintStyle: AppTextStyles.style14Regular.copyWith(
                        color: colors.neutral500,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      border: limitFieldBorder,
                      enabledBorder: limitFieldBorder,
                      focusedBorder: limitFieldBorder.copyWith(
                        borderSide: BorderSide(color: colors.primary500Main),
                      ),
                    ),
                    onChanged: (value) {
                      final double? parsed = double.tryParse(value);
                      if (parsed == null) return;
                      updateRange(
                        RangeValues(
                          priceRange.start,
                          parsed.clamp(priceRange.start, FilterPriceView.maxPrice),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    LangKeys.minimumLimitKey.tr(),
                    style: AppTextStyles.style14Medium.copyWith(
                      color: colors.neutral1200,
                    ),
                  ),
                  TextFormField(
                    controller: minLimitController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    style: AppTextStyles.style14Regular.copyWith(
                      color: colors.neutral1200,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: LangKeys.minimumLimitKey.tr(),
                      hintStyle: AppTextStyles.style14Regular.copyWith(
                        color: colors.neutral500,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      border: limitFieldBorder,
                      enabledBorder: limitFieldBorder,
                      focusedBorder: limitFieldBorder.copyWith(
                        borderSide: BorderSide(color: colors.primary500Main),
                      ),
                    ),
                    onChanged: (value) {
                      final double? parsed = double.tryParse(value);
                      if (parsed == null) return;
                      updateRange(
                        RangeValues(
                          parsed.clamp(FilterPriceView.minPrice, priceRange.end),
                          priceRange.end,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Yellow slider thumb with a soft halo ring, matching the Figma range
/// slider (28px sub-container with an inner dot).
class _FilterSliderThumbShape extends RangeSliderThumbShape {
  const _FilterSliderThumbShape({
    required this.thumbColor,
    required this.haloColor,
  });

  final Color thumbColor;
  final Color haloColor;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(28, 28);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    TextDirection textDirection = TextDirection.ltr,
    required SliderThemeData sliderTheme,
    Thumb thumb = Thumb.start,
    bool isPressed = false,
  }) {
    final Canvas canvas = context.canvas;
    canvas.drawCircle(center, 14, Paint()..color = haloColor);
    canvas.drawCircle(center, 8, Paint()..color = thumbColor);
  }
}
