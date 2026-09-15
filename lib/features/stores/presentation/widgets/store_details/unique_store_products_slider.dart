import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/offer_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_arrow_slider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_brand_info_card.dart';

class UniqueStoreProductsSlider extends ConsumerWidget {
  const UniqueStoreProductsSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final List<OfferModel>? offers = ref.watch(storeProvider).offers;
    final List<ProductModel> products =
        (offers != null && offers.isNotEmpty ? offers.first.products : null) ??
        const [];
    if (products.isEmpty) return const SizedBox.shrink();

    return AppArrowSlider(
      itemCount: products.length,
      aboveImageBuilder: (BuildContext context, int index) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (Rect bounds) => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.9],
          colors: [
            colors.secondaryFixedDim.withValues(alpha: 0.2),
            colors.secondaryFixedDim,
          ],
        ).createShader(bounds),
        child: Align(
          alignment: AlignmentDirectional.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              context.getLocalizedApiText(products[index].name).toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 65,
                height: 0,
                color: colors.secondaryFixedDim,
              ),
            ),
          ),
        ),
      ),
      sliderItemBuilder: (BuildContext context, int index) => Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadiusGeometry.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.secondaryFixedDim.withValues(alpha: 0.4),
              offset: Offset(0, 20),
              blurRadius: 100,
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 1.3,
          child: AppCachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: (products[index].images?.isNotEmpty ?? false)
                ? products[index].images!.first
                : '',
          ),
        ),
      ),
      belowImageBuilder: (BuildContext context, int index) =>
          StoreDetailsBrandInfoCard(product: products[index]),
      sliderSpace: 0,
      itemHeight: 600,
      activeDotColor: colors.secondaryFixedDim,
      dotColor: colors.neutral200,
    );
  }
}
