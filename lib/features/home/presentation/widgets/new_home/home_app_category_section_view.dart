import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_view_all_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

class HomeAppCategorySectionView extends StatelessWidget {
  const HomeAppCategorySectionView({
    super.key,
    required this.categoryModel,
    required this.productModels,
    this.showBanner = false,
  });

  final CategoryModel categoryModel;
  final List<ProductModel> productModels;
  final bool showBanner;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double productRowHeight = constraints.maxWidth * 0.78;
        return Stack(
          children: [
            Positioned.fill(
              child: ReverseWidget(
                applyReverse: !context.isRTL,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (Rect bounds) => LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    stops: [0, 0.5],
                    colors: [
                      colors.onInverseSurface.withValues(alpha: 0.2),
                      colors.onInverseSurface.withValues(alpha: 0.02),
                    ],
                  ).createShader(bounds),
                  child: Assets.media.images.svg.oneWaveBackground.svg(
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 20,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        context.getLocalizedApiText(categoryModel.name),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.black,
                        ),
                      ),
                      HomeViewAllWidget(
                        size: 15,
                        startBackgroundColor: colors.onInverseSurface.withValues(
                          alpha: 0.5,
                        ),
                        endBackgroundColor: colors.onInverseSurface.withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: productRowHeight,
                  child: ListView.separated(
                    padding: EdgeInsetsDirectional.only(
                      start: 16
                    ),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return ProductItem3View();
                    },
                    separatorBuilder: (context, index) => 4.wSpace,
                    itemCount: productModels.length,
                  ),
                ),
                if (showBanner)
                  AspectRatio(
                    aspectRatio: 3.5,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: colors.black.withValues(alpha: 0.25),
                            offset: Offset.zero,
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const AppCachedNetworkImage(
                        imageUrl:
                            'https://as1.ftcdn.net/jpg/02/29/54/06/1000_F_229540688_nriN1k76uBt2lHMU9dMV2DbbXWGYPUj2.jpg',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}