import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/formatters/name_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/text_field.dart';

/// Personal-information card for the post-OTP profile step: full name and an
/// optional email.
///
/// Deliberately stateless — the controllers belong to the screen, which has to
/// read them to validate and save. It only renders what it is handed.
class CompleteProfileForm extends StatelessWidget {
  const CompleteProfileForm({
    super.key,
    required this.fullName,
    required this.email,
    this.nameError,
    this.emailError,
    this.maxNameLength = 80,
  });

  final TextEditingController fullName;
  final TextEditingController email;
  final String? nameError;
  final String? emailError;
  final int maxNameLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.onTertiaryContainer.withAlpha(210),
        borderRadius: AppBorderRadius.brCircular20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LangKeys.fullNameKey.tr(),
            style: AppTextStyles.style14Medium.copyWith(
              color: context.colors.neutral500,
            ),
          ),
          const SizedBox(height: 8),
          RoundedField(
            controller: fullName,
            hint: LangKeys.nameHintKey.tr(),
            maxLength: maxNameLength,
            inputFormatters: <TextInputFormatter>[nameInputFormatter],
          ),
          if (nameError != null) _error(context, nameError!),
          const SizedBox(height: 16),
          Text(
            LangKeys.emailOptionalKey.tr(),
            style: AppTextStyles.style14Medium.copyWith(
              color: context.colors.neutral500,
            ),
          ),
          const SizedBox(height: 8),
          RoundedField(
            controller: email,
            hint: LangKeys.enterYourEmailKey.tr(),
            keyboardType: TextInputType.emailAddress,
            maxLength: 80,
            // An address is Latin text. Laid out RTL, Arabic reorders it
            // around `@` and `.`.
            textDirection: TextDirection.ltr,
          ),
          if (emailError != null) _error(context, emailError!),
        ],
      ),
    );
  }

  Widget _error(BuildContext context, String message) => Padding(
    padding: const EdgeInsetsDirectional.only(start: 16, top: 6),
    child: Text(
      message,
      style: AppTextStyles.style12Regular.copyWith(
        color: context.colors.red300Main,
      ),
    ),
  );
}
