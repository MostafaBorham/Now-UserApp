import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/carousel_hold.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/featured_stores_controller.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_featured_store_item.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';

/// The `featured_stores` section: a full-width carousel with one page per
/// store, each page showing that store's header and a 2×2 grid of its products
/// (see [HomeFeaturedStoreItem]).
///
/// The feed sends the products inline with each store, so this section needs no
/// fetch of its own. Stores arriving without products are dropped — their page
/// would be an empty grid.
class HomeFeaturedStoresView extends ConsumerWidget {
  const HomeFeaturedStoresView({super.key, required this.stores});

  final List<StoreModel> stores;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<StoreModel> visible = stores
        .where(
          (StoreModel store) =>
              (store.products ?? const <ProductModel>[]).isNotEmpty,
        )
        .toList();

    if (visible.isEmpty) return const SizedBox.shrink();

    final bool isSingleStore = visible.length == 1;

    return CarouselHold(
      builder: (CarouselSliderController controller) => CarouselSlider.builder(
        carouselController: controller,
        itemCount: visible.length,
        itemBuilder: (_, index, _) => RepaintBoundary(
          child: HomeFeaturedStoreItem(
            store: visible[index],
            storesCount: visible.length,
            onProductFavouriteChanged: (int? productId, bool isFavourite) => ref
                .read(getHomeSectionsProvider.notifier)
                .updateProductFavourite(productId, isFavourite),
          ),
        ),
        options: CarouselOptions(
          onPageChanged: isSingleStore
              ? null
              : (index, reason) =>
                    ref.read(currentFeaturedStoreIndexProvider.notifier).state =
                        index,
          enlargeCenterPage: false,
          autoPlay: !isSingleStore,
          autoPlayInterval: const Duration(seconds: 5),
          pauseAutoPlayOnTouch: false,
          // Drift right-to-left in Arabic, left-to-right in English — see the
          // motion rule on `AppSlider`.
          reverse: true,
          scrollPhysics: isSingleStore
              ? const NeverScrollableScrollPhysics()
              : null,
          aspectRatio: 0.75,
          viewportFraction: 1,
        ),
      ),
    );
  }
}
