import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/text_field.dart';

/// Personal-information card: name (first + last) with a live character counter
/// and an optional email.
class PersonalInfoForm extends StatefulWidget {
  const PersonalInfoForm({super.key, this.maxNameLength = 40});

  final int maxNameLength;

  @override
  State<PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {
  final TextEditingController _firstName = TextEditingController(text: 'Ahmed');
  final TextEditingController _lastName = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstName.addListener(_refresh);
    _lastName.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  int get _nameLength => _firstName.text.length + _lastName.text.length;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.onTertiaryContainer,
        borderRadius: AppBorderRadius.brCircular20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  LangKeys.nameKey.tr(),
                  style: AppTextStyles.style14Medium.copyWith(
                    color: context.colors.neutral500,
                  ),
                ),
              ),
              Text(
                '$_nameLength/${widget.maxNameLength}',
                style: AppTextStyles.style12Regular.copyWith(
                  color: context.colors.neutral500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RoundedField(
                  controller: _firstName,
                  hint: LangKeys.firstNameHintKey.tr(),
                  maxLength: widget.maxNameLength,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RoundedField(
                  controller: _lastName,
                  hint: LangKeys.lastNameHintKey.tr(),
                  maxLength: widget.maxNameLength,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            LangKeys.emailOptionalKey.tr(),
            style: AppTextStyles.style14Medium.copyWith(
              color: context.colors.neutral500,
            ),
          ),
          const SizedBox(height: 8),
          RoundedField(
            hint: LangKeys.enterYourEmailKey.tr(),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }
}
