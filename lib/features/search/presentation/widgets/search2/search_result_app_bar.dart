import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search2_back_button.dart';

class SearchResultAppBar extends StatelessWidget {
  const SearchResultAppBar({
    super.key,
    required this.searchField,
    required this.onBack,
  });

  final Widget searchField;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.white,
        border: Border(bottom: BorderSide(color: colors.neutral200)),
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 5, 16, 8),
          child: Row(
            spacing: 8,
            children: [
              Search2BackButton(onPressed: onBack),
              Expanded(child: searchField),
            ],
          ),
        ),
      ),
    );
  }
}
