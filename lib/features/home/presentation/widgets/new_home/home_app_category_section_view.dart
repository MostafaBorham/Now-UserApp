import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/products/product_details_list_scope.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_view_all_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';

class HomeAppCategorySectionView extends ConsumerWidget {
  const HomeAppCategorySectionView({
    super.key,
    required this.categoryModel,
    required this.productModels,
    this.primaryColor,
    this.textColor,
    this.showViewAll = true,
    this.onViewAllTap,
  });

  final CategoryModel categoryModel;
  final List<ProductModel> productModels;

  final Color? primaryColor;
  final Color? textColor;
  final bool showViewAll;

  /// Opens the section's category; see `openHomeCategory`.
  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final Color accent = primaryColor ?? colors.onInverseSurface;
    final Color titleColor = textColor ?? colors.black;
    return ProductDetailsListScope(
      productSlugs: () => productModels.map((product) => product.slug),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double productRowHeight = constraints.maxWidth * 245 / 390;
          return Stack(
            children: [
              Positioned.fill(
                child: ReverseWidget(
                  applyReverse: !context.isRTL,
                  child: HomeCategoryWave(
                    wave: HomeCategoryWave.oneWave,
                    viewBox: HomeCategoryWave.oneWaveViewBox,
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      stops: [0.0, 0.80],
                      colors: [accent.withAlpha(120), colors.white],
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 20,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ).copyWith(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            context.getLocalizedApiText(categoryModel.name),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                        ),

                        if (showViewAll)
                          HomeViewAllWidget(
                            onTap: onViewAllTap,
                            size: 15,
                            textColor: titleColor,
                            startBackgroundColor: colors.white,
                            endBackgroundColor: accent.withValues(alpha: 0.5),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: productRowHeight,
                    child: ListView.separated(
                      padding: EdgeInsetsDirectional.only(start: 16),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return ProductItem3View(
                          product: productModels[index],
                          onFavouriteChanged: (bool isFavourite) => ref
                              .read(getHomeSectionsProvider.notifier)
                              .updateProductFavourite(
                                productModels[index].id,
                                isFavourite,
                              ),
                        );
                      },
                      separatorBuilder: (context, index) => 4.wSpace,
                      itemCount: productModels.length,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A products-by-category section's wave backdrop: the wave SVG's own path,
/// stretched over the box like `BoxFit.fill` and filled with [gradient] in one
/// draw. It used to be the SVG under a `ShaderMask`, which cost a `saveLayer` —
/// an offscreen pass — on every frame a category section was on screen.
class HomeCategoryWave extends StatelessWidget {
  const HomeCategoryWave({
    super.key,
    required this.wave,
    required this.viewBox,
    required this.gradient,
  });

  /// The wave, in [viewBox] units.
  final Path wave;
  final Size viewBox;
  final Gradient gradient;

  /// The path of the former `one-wave-background.svg`.
  static final Path oneWave = Path()
    ..moveTo(1277, 71.7471)
    ..cubicTo(1277, 71.7471, 1044.7, 194.84, 684.261, 57.5441)
    ..cubicTo(323.825, -79.7521, -1, 71.7471, -1, 71.7471)
    ..lineTo(-1, 303)
    ..lineTo(1277, 303)
    ..close();
  static const Size oneWaveViewBox = Size(390, 303);

  /// The path of the former `two-wave-background.svg`.
  static final Path twoWave = Path()
    ..moveTo(513, 0)
    ..cubicTo(463.512, 0, 424.949, 38.8393, 302.031, 8.52637)
    ..cubicTo(179.114, -21.7867, 111.629, 40.5428, 29.6836, 40.543)
    ..cubicTo(-52.2617, 40.5429, -104, 8.52637, -104, 8.52637)
    ..lineTo(-104, 290.046)
    ..cubicTo(-104, 290.046, 1.40488, 264.091, 119.342, 290.046)
    ..cubicTo(237.278, 316, 210.606, 301.413, 338.184, 290.046)
    ..cubicTo(465.761, 278.679, 513, 316, 513, 316)
    ..close();
  static const Size twoWaveViewBox = Size(390, 316);

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: CustomPaint(painter: _WavePainter(wave, viewBox, gradient)),
  );
}

class _WavePainter extends CustomPainter {
  const _WavePainter(this.wave, this.viewBox, this.gradient);

  final Path wave;
  final Size viewBox;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect box = Offset.zero & viewBox;
    canvas
      ..clipRect(Offset.zero & size)
      ..scale(size.width / viewBox.width, size.height / viewBox.height)
      ..drawPath(wave, Paint()..shader = gradient.createShader(box));
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.wave != wave || old.viewBox != viewBox || old.gradient != gradient;
}
