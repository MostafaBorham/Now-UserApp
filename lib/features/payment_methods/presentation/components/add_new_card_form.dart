import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/input_direction.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_context_menu.dart';

/// The "Add New Card" entry form — a light card holding the cardholder name,
/// card number (with brand logos), expiry date and CVV, split by hairlines.
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
            // Digits: the groups of a card number come out reversed RTL.
            isLtr: true,
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
                    isLtr: true,
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
                    isLtr: true,
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

/// A single labelled field: muted label on top, editable value below,
/// with optional trailing content (used for the card-number brand logos).
///
/// Owns its text in a [TextEditingController] seeded from [initialValue], so
/// the field can flip between LTR and RTL with what is being typed the way
/// every other input in the app does. [isLtr] pins the direction instead —
/// card numbers, expiry dates and CVVs read left-to-right even in Arabic.
class _CardField extends StatefulWidget {
  const _CardField({
    required this.label,
    required this.initialValue,
    this.keyboardType,
    this.trailing,
    this.isLtr = false,
  });

  final String label;
  final String initialValue;
  final TextInputType? keyboardType;
  final Widget? trailing;
  final bool isLtr;

  @override
  State<_CardField> createState() => _CardFieldState();
}

class _CardFieldState extends State<_CardField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.style14Regular.copyWith(
            color: context.colors.neutral500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: InputDirectionBuilder(
                controller: _controller,
                builder:
                    (BuildContext context, TextDirection? typedDirection) =>
                        TextFormField(
                          contextMenuBuilder: appContextMenuBuilder,
                          controller: _controller,
                          keyboardType: widget.keyboardType,
                          textDirection: widget.isLtr
                              ? TextDirection.ltr
                              : typedDirection,
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
            ),
            if (widget.trailing != null) ...[
              const SizedBox(width: 8),
              widget.trailing!,
            ],
          ],
        ),
      ],
    );
  }
}

/// Full-width hairline between the form's fields.
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
