import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';

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
    final Gradient screenGradient = LinearGradient(
      colors: [
        colors.secondaryFixed,
        colors.primary,
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: const [0, 1],
    );
    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: AppBorderRadius.brCircular30,
        border: Border.all(
          color: colors.onPrimary
        )
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Center(
              child: Icon(
                Icons.language,
                size: 18,
                color: colors.primary,
              ),
            ),
          ),
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
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        width: thumbWidth,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: screenGradient,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _LanguageItem(
                            title: 'EN',
                            selected: isEnglish,
                            onTap: () => _selectLanguage(AppLanguage.en),
                          ),
                        ),
                        Expanded(
                          child: _LanguageItem(
                            title: 'AR',
                            selected: !isEnglish,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF1F2A1F),
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }
}