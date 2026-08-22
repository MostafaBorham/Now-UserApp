import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';

/// The search bar that pins to the top of [HomeView] once the in-header search
/// field scrolls up to the top of the page. It mirrors the header search field
/// and sits on a solid amber background so it stays readable over the content
/// that scrolls beneath it.
class HomePinnedSearchBar extends StatelessWidget {
  const HomePinnedSearchBar({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.primary500Main,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: PrimarySearchField(onTap: onTap),
        ),
      ),
    );
  }
}
