import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_view_all_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

class HomeAppCategorySectionView extends StatelessWidget {
  const HomeAppCategorySectionView({
    super.key,
    required this.categoryModel,
    required this.productModels,
  });

  final CategoryModel categoryModel;
  final List<ProductModel> productModels;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Stack(
      children: [
        Positioned.fill(
          child: ReverseWidget(
            applyReverse: !context.isRTL,
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (Rect bounds) => LinearGradient(
                begin: !context.isRTL
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                end: !context.isRTL
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
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
            Expanded(
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
          ],
        ),
      ],
    );
  }
}