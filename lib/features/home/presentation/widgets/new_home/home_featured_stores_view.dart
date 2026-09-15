import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/featured_stores_controller.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_featured_store_item.dart';








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

    return CarouselSlider.builder(
      itemCount: visible.length,
      itemBuilder: (_, index, _) => RepaintBoundary(
        child: HomeFeaturedStoreItem(
          store: visible[index],
          storesCount: visible.length,
        ),
      ),
      options: CarouselOptions(
        onPageChanged: isSingleStore
            ? null
            : (index, reason) => ref
                  .read(currentFeaturedStoreIndexProvider.notifier)
                  .state = index,
        enlargeCenterPage: false,
        autoPlay: !isSingleStore,


        reverse: true,
        scrollPhysics: isSingleStore
            ? const NeverScrollableScrollPhysics()
            : null,
        aspectRatio: 0.75,
        viewportFraction: 1,
      ),
    );
  }
}
