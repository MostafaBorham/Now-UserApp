import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/bottom_concave_arc_clipper.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search2_back_button.dart';

class Search2AppBar extends StatelessWidget {
  const Search2AppBar({super.key, required this.searchField});

  final Widget searchField;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return LayoutBuilder(
      builder: (context, con) {
        final double backButtonSize = MediaQuery.sizeOf(context).width * 0.1;

        return Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, box) {
                  final double glowRadius = box.maxWidth / 2;
                  return ClipPath(
                    clipper: const BottomConcaveArcClipper(),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topCenter,
                          radius: glowRadius / box.biggest.shortestSide,
                          colors: [
                            colors.onSecondaryFixed.withValues(alpha: 0.7),
                            colors.onSecondaryFixed,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: con.maxWidth * 0.06,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (context.canPop())
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: const Search2BackButton(),
                          ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: backButtonSize + 8,
                          ),
                          child: Text(
                            LangKeys.search2TitleKey.tr(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.style24SemiBold.copyWith(
                              color: colors.black,
                              fontSize: con.maxWidth * 0.05,
                            ),
                          ),
                        ),
                      ],
                    ),
                    searchField,
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
