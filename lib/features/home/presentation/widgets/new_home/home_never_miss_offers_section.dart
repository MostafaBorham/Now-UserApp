import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/lists/infinite_auto_scroll_list.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_banner_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_never_miss_offers_item.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_view_all_widget.dart';

class HomeNeverMissOffersSection extends StatelessWidget {
  const HomeNeverMissOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.inverseSurface.withValues(alpha: 0.9), colors.white],
                stops: [0, 0.7],
              ),
            ),
            child: Assets.media.images.svg.homeNeverMissOffersBackground.svg(
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context,con) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 5,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        context.isRTL? Assets.media.images.png.homeNeverMissOffersLogo.image(
                          width: con.maxWidth*0.35,
                        ) : Assets.media.images.png.englishOffersCannotMissLogo.image(
                          width: con.maxWidth*0.35,
                        ),
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: HomeViewAllWidget(
                              size: 16,
                              startBackgroundColor: colors.inverseSurface,
                              endBackgroundColor: colors.inverseSurface.withValues(
                                alpha: 0.7,
                              ),
                              textColor: colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, listCon) {
                        final double itemHeight = listCon.maxHeight - 4;
                        return InfiniteAutoScrollList(
                          itemCount: 10,
                          itemWidth: itemHeight * 0.55,
                          separatorWidth: 10,
                          padding: const EdgeInsetsDirectional.only(bottom: 4),
                          itemBuilder: (context, index) =>
                              const HomeNeverMissOffersItem(),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ],
    );
  }
}
