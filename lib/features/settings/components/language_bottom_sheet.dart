import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/constants.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Bottom sheet for picking the app language, opened from the "Language"
/// row on the Profile/Settings screen.
class LanguageBottomSheet extends StatelessWidget {
  const LanguageBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const LanguageBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.locale == LocalizationConstants.arabicLocale;

    void select(Locale locale) {
      context.setLocale(locale);
      context.pop();
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.neutral500,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  LangKeys.language.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.colors.tertiaryContainer,
                  ),
                ),
              ),
              InkWell(
                onTap: () => context.pop(),
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 24,
                    color: context.colors.tertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 24, color: context.colors.neutral200),
          _LanguageOption(
            label: LangKeys.languageAr.tr(),
            selected: isArabic,
            onTap: () => select(LocalizationConstants.arabicLocale),
          ),
          Divider(height: 1, color: context.colors.neutral200),
          _LanguageOption(
            label: LangKeys.languageEn.tr(),
            selected: !isArabic,
            onTap: () => select(LocalizationConstants.englishLocale),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: context.colors.tertiaryContainer,
                ),
              ),
            ),
            if (selected) Assets.media.images.svg.tickCircle.svg(),
          ],
        ),
      ),
    );
  }
}
