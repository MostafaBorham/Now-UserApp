import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/formatters/arabic_kashida_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_view_all_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

class HomeAppCategoryWithLogoSectionView extends StatelessWidget {
  const HomeAppCategoryWithLogoSectionView({
    super.key,
    required this.categoryModel,
    required this.productModels,
  });

  final CategoryModel categoryModel;
  final List<ProductModel> productModels;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context,con) {
        return Stack(
          children: [
            Positioned.fill(
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (Rect bounds) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.8],
                  colors: [colors.error.withValues(alpha: 0.7), colors.white],
                ).createShader(bounds),
                child: ReverseWidget(
                  applyReverse: !context.isRTL,
                  child: Padding(
                    padding: EdgeInsets.only(top: con.maxWidth*0.035),
                    child: Assets.media.images.svg.twoWaveBackground.svg(
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              spacing: 5,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatArabicKashida(
                                  context.getLocalizedApiText(categoryModel.name),
                                  count: 20,
                                ),
                                style: TextStyle(
                                  fontSize: con.maxWidth*0.04,
                                  fontWeight: FontWeight.bold,
                                  color: colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.only(start: 12.0),
                                child: Text(
                                  formatArabicKashida(
                                    LangKeys.perfumeTaglineKey.tr(),
                                    count: 20,
                                  ),
                                  style: TextStyle(
                                    fontSize: con.maxWidth*0.04,
                                    fontWeight: FontWeight.bold,
                                    color: colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: con.maxWidth*0.3,
                            child: CachedNetworkImage(
                              imageUrl:
                              'https://cdn.phototourl.com/free/2026-08-16-86628689-05f6-46bf-adef-552e544d537c.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                              placeholder: (context, url) => const SizedBox.shrink(),
                              errorWidget: (context, url, error) => const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      HomeViewAllWidget(
                        size: con.maxWidth*0.04,
                        startBackgroundColor: colors.error.withValues(
                          alpha: 0.3,
                        ),
                        endBackgroundColor: colors.error.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsetsDirectional.only(start: 16),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return ProductItem3View();
                    },
                    separatorBuilder: (context, index) => 4.wSpace,
                    itemCount: productModels.length,
                  ),
                ),
              ],
            ),
          ],
        );
      }
    );
  }
}
