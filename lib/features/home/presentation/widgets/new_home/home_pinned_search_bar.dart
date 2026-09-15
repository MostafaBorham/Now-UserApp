import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';

class HomePinnedSearchBar extends StatelessWidget {
  const HomePinnedSearchBar({super.key, required this.progress, this.onTap});

  final double progress;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final double t = progress.clamp(0.0, 1.0);
    return Stack(
      children: <Widget>[

        Positioned.fill(
          child: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: t,
              child: ColoredBox(
                color: colors.primary500Main,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: PrimarySearchField(onTap: onTap),
          ),
        ),
      ],
    );
  }
}
