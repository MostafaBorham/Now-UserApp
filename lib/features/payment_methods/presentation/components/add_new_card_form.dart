import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';



class AddNewCardForm extends StatelessWidget {
  const AddNewCardForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: context.colors.onTertiaryContainer,
        borderRadius: AppBorderRadius.brCircular20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardField(
            label: LangKeys.cardholderNameKey.tr(),
            initialValue: 'Yasser Ahmed',
          ),
          const _FormDivider(),
          _CardField(
            label: LangKeys.cardNumberKey.tr(),
            initialValue: '2547 7487 4781 5241',
            keyboardType: TextInputType.number,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.media.images.svg.masterCard.svg(height: 16),
                const SizedBox(width: 8),
                Assets.media.images.svg.visa.svg(height: 12),
              ],
            ),
          ),
          const _FormDivider(),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _CardField(
                    label: LangKeys.expirationDateKey.tr(),
                    initialValue: '11/2025',
                    keyboardType: TextInputType.datetime,
                  ),
                ),
                VerticalDivider(
                  width: 32,
                  thickness: 1,
                  color: context.colors.neutral200,
                ),
                Expanded(
                  child: _CardField(
                    label: LangKeys.cvvKey.tr(),
                    initialValue: '487',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _CardField extends StatelessWidget {
  const _CardField({
    required this.label,
    required this.initialValue,
    this.keyboardType,
    this.trailing,
  });

  final String label;
  final String initialValue;
  final TextInputType? keyboardType;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.style14Regular.copyWith(
            color: context.colors.neutral500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: initialValue,
                keyboardType: keyboardType,
                style: AppTextStyles.style16Medium.copyWith(
                  color: context.colors.tertiaryContainer,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ],
    );
  }
}


class _FormDivider extends StatelessWidget {
  const _FormDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Divider(height: 1, thickness: 1, color: context.colors.neutral200),
    );
  }
}
