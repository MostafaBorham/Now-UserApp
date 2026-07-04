import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

enum AppLanguage { en, ar }

class AppLanguageToggleWidget extends StatefulWidget {
  const AppLanguageToggleWidget({
    super.key,
    this.initialLanguage = AppLanguage.en,
    this.onChanged,
    this.width = 132,
    this.height = 40,
  });

  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onChanged;
  final double width;
  final double height;

  @override
  State<AppLanguageToggleWidget> createState() => _AppLanguageToggleWidgetState();
}

class _AppLanguageToggleWidgetState extends State<AppLanguageToggleWidget> {
  late AppLanguage _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage;
  }

  void _selectLanguage(AppLanguage language) {
    if (_selectedLanguage == language) return;
    setState(() => _selectedLanguage = language);
    widget.onChanged?.call(language);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = _selectedLanguage == AppLanguage.en;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(999);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: LiquidGlassLens(
          style: LiquidGlassStyle(
            shape: LiquidGlassShape.squircle(cornerRadius: 36,borderType: OpticalBorder(
              borderSolidity: 5,
            ),lightDirection: 20,lightColor: colors.onPrimary),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13,vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double toggleWidth = constraints.maxWidth;
                      final double thumbWidth = toggleWidth / 2;

                      return Stack(
                        children: [
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            alignment: isEnglish
                                ? AlignmentDirectional.centerStart
                                : AlignmentDirectional.centerEnd,
                            child: Container(
                              width: thumbWidth,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colors.secondaryFixed,
                                    colors.primary,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  stops: const [0, 0.8],
                                ),
                                borderRadius: borderRadius,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _LanguageItem(
                                  title: 'EN',
                                  selected: _selectedLanguage == AppLanguage.en,
                                  onTap: () => _selectLanguage(AppLanguage.en),
                                ),
                              ),
                              Expanded(
                                child: _LanguageItem(
                                  title: 'AR',
                                  selected: _selectedLanguage == AppLanguage.ar,
                                  onTap: () => _selectLanguage(AppLanguage.ar),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
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

class _LanguageItem extends StatelessWidget {
  const _LanguageItem({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: selected ? null : onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            style: AppTextStyles.style12Medium.copyWith(
              color: selected ? colors.onPrimary : colors.tertiaryContainer,
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }
}