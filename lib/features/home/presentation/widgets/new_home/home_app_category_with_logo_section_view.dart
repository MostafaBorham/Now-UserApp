import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/formatters/arabic_kashida_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_view_all_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';








class HomeAppCategoryWithLogoSectionView extends StatelessWidget {
  const HomeAppCategoryWithLogoSectionView({
    super.key,
    required this.categoryModel,
    required this.productModels,
    this.imageUrl,
    this.primaryColor,
    this.textColor,
    this.showViewAll = true,
  });

  final CategoryModel categoryModel;
  final List<ProductModel> productModels;



  final String? imageUrl;



  final Color? primaryColor;
  final Color? textColor;
  final bool showViewAll;


  static const double _designWidth = 390;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color accent = primaryColor ?? colors.error;
    final String image = imageUrl ?? '';
    return LayoutBuilder(
      builder: (context, con) {
        final double s = con.maxWidth / _designWidth;
        return SizedBox(
          height: 317 * s,
          child: Stack(
            clipBehavior: Clip.none,
            children: [


              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 316 * s,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (Rect bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.803],
                    colors: [accent, colors.white],
                  ).createShader(bounds),
                  child: ReverseWidget(
                    applyReverse: !context.isRTL,
                    child: Assets.media.images.svg.twoWaveBackground.svg(
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),




              if (image.isNotEmpty)
                PositionedDirectional(
                  start: 175 * s,
                  top: -28 * s,
                  width: 164 * s,
                  height: 100 * s,
                  child: CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    placeholder: (context, url) => const SizedBox.shrink(),
                    errorWidget: (context, url, error) => const SizedBox.shrink(),
                  ),
                ),


              PositionedDirectional(
                start: 43 * s,
                top: 14 * s,
                width: 157 * s,
                child: Text(
                  formatArabicKashida(
                    context.getLocalizedApiText(categoryModel.name),
                    count: 20,
                  ),
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.486 * s,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: textColor ?? colors.white,
                  ),
                ),
              ),




              if (showViewAll)
                PositionedDirectional(
                  end: 16 * s,
                  top: 10 * s,
                  child: HomeViewAllWidget(
                    size: con.maxWidth * 0.04,
                    startBackgroundColor: accent.withValues(alpha: 0.3),
                    endBackgroundColor: accent.withValues(alpha: 0.1),
                  ),
                ),

              Positioned(
                left: 0,
                right: 0,
                top: 72 * s,
                bottom: 0,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: productModels.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) =>
                      ProductItem3View(product: productModels[index]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
