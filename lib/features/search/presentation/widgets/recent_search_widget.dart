import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class RecentSearchWidget extends StatefulWidget {
  const RecentSearchWidget({
    super.key,
    required this.keywords,
    this.onRemove,
    this.onClear,
    this.onSelect,
  });

  final List<String> keywords;
  final ValueChanged<String>? onRemove;
  final VoidCallback? onClear;
  final ValueChanged<String>? onSelect;

  @override
  State<RecentSearchWidget> createState() => _RecentSearchWidgetState();
}

class _RecentSearchWidgetState extends State<RecentSearchWidget> {
  late List<String> _keywords = List<String>.of(widget.keywords);

  @override
  void didUpdateWidget(covariant RecentSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.keywords, oldWidget.keywords)) {
      _keywords = List<String>.of(widget.keywords);
    }
  }

  void _onRemove(String term) {
    setState(() => _keywords.remove(term));
    widget.onRemove?.call(term);
  }

  void _onClear() {
    setState(_keywords.clear);
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_keywords.isEmpty) return const SizedBox.shrink();
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              LangKeys.recentKey.tr(),
              style: AppTextStyles.style18SemiBold.copyWith(
                color: colors.onSecondary,
              ),
            ),
            InkWell(
              onTap: _onClear,
              child: Text(
                LangKeys.clearKey.tr(),
                style: AppTextStyles.style14Medium.copyWith(
                  color: colors.errorContainer,
                ),
              ),
            ),
          ],
        ),
        ..._keywords.map(
          (String term) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () => widget.onSelect?.call(term),
                  child: Text(
                    term,
                    maxLines: 1,
                    style: AppTextStyles.style16Regular.copyWith(
                      color: colors.tertiaryContainer,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => _onRemove(term),
                child: Icon(
                  Icons.close,
                  size: 22,
                  color: colors.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
