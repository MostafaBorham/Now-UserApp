import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';
import 'package:nowdelivery_user_app/features/home/data/repo/home_sections_repo.dart';

/// Single task: fetch the ordered home feed that drives the Home tab.
///
/// Kept alive (not `autoDispose`) — the Home tab stays mounted, so the feed is
/// fetched once and reused (mirrors `getFeaturedStoresProvider`). The fetch is
/// kicked from [HomeView] rather than the provider factory because it needs a
/// `BuildContext` to resolve the current locale (`lang`) and the platform.
final getHomeSectionsProvider = StateNotifierProvider<GetHomeSectionsViewModel,
    AsyncValue<List<HomeSectionModel>>>(
  (Ref ref) => GetHomeSectionsViewModel(),
);

class GetHomeSectionsViewModel
    extends StateNotifier<AsyncValue<List<HomeSectionModel>>> {
  GetHomeSectionsViewModel() : super(const AsyncValue.loading());

  final HomeSectionsRepo _repo = HomeSectionsRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  /// Flips a product's favourite status wherever it appears in the loaded feed
  /// so the change survives scrolling the card out of view and back. The feed is
  /// kept alive and its cards seed their favourite icon from the cached model,
  /// so a toggle that is not written back here is lost the moment the card is
  /// rebuilt. A product shows up either directly in a `flash_offers` /
  /// `products_by_category` section or nested in a `featured_stores` store's
  /// grid, so both are updated.
  void updateProductFavourite(int? productId, bool isFavourite) {
    if (productId == null) return;
    final List<HomeSectionModel>? sections = state.valueOrNull;
    if (sections == null) return;

    state = AsyncValue<List<HomeSectionModel>>.data(<HomeSectionModel>[
      for (final HomeSectionModel section in sections)
        _sectionWithProductFavourite(section, productId, isFavourite),
    ]);
  }

  /// Flips a store's favourite status wherever it appears in the loaded feed
  /// (`nearby_stores`, `all_stores` and `featured_stores`), for the same reason
  /// as [updateProductFavourite].
  void updateStoreFavourite(int? storeId, bool isFavourite) {
    if (storeId == null) return;
    final List<HomeSectionModel>? sections = state.valueOrNull;
    if (sections == null) return;

    state = AsyncValue<List<HomeSectionModel>>.data(<HomeSectionModel>[
      for (final HomeSectionModel section in sections)
        _sectionWithStoreFavourite(section, storeId, isFavourite),
    ]);
  }

  HomeSectionModel _sectionWithProductFavourite(
    HomeSectionModel section,
    int productId,
    bool isFavourite,
  ) {
    final List<ProductModel> products = section.products;
    final bool hasDirect =
        products.any((ProductModel product) => product.id == productId);

    final List<StoreModel> stores = section.stores;
    final bool hasNested = stores.any(
      (StoreModel store) => (store.products ?? const <ProductModel>[])
          .any((ProductModel product) => product.id == productId),
    );

    if (!hasDirect && !hasNested) return section;

    return section.copyWith(
      products: hasDirect
          ? <ProductModel>[
              for (final ProductModel product in products)
                product.id == productId
                    ? product.copyWith(isFavorite: isFavourite)
                    : product,
            ]
          : products,
      stores: hasNested
          ? <StoreModel>[
              for (final StoreModel store in stores)
                store.copyWith(
                  products: <ProductModel>[
                    for (final ProductModel product
                        in store.products ?? const <ProductModel>[])
                      product.id == productId
                          ? product.copyWith(isFavorite: isFavourite)
                          : product,
                  ],
                ),
            ]
          : stores,
    );
  }

  HomeSectionModel _sectionWithStoreFavourite(
    HomeSectionModel section,
    int storeId,
    bool isFavourite,
  ) {
    final List<StoreModel> stores = section.stores;
    if (!stores.any((StoreModel store) => store.id == storeId)) return section;

    return section.copyWith(
      stores: <StoreModel>[
        for (final StoreModel store in stores)
          store.id == storeId
              ? store.copyWith(isFavorite: isFavourite)
              : store,
      ],
    );
  }

  /// [lat] / [lng] are the device's cached coordinates for the `nearby_stores`
  /// section. The backend prefers a signed-in user's default address and only
  /// falls back to these (see [HomeView]).
  ///
  /// A refresh keeps the already-loaded sections as the previous value, so the
  /// feed stays on screen instead of flashing back to its shimmer; a failure
  /// keeps them too, with the error alongside.
  Future<void> getHomeSections({
    required String platform,
    required String lang,
    double? lat,
    double? lng,
  }) async {
    _lastQuery = (platform: platform, lang: lang, lat: lat, lng: lng);
    state = const AsyncValue<List<HomeSectionModel>>.loading()
        .copyWithPrevious(state);

    final result = await _repo.getHomeSections(
      platform: platform,
      lang: lang,
      lat: lat,
      lng: lng,
    );

    if (!mounted) return;

    state = result.fold(
      (Failure failure) => AsyncValue<List<HomeSectionModel>>.error(
        failure.message,
        StackTrace.current,
      ).copyWithPrevious(state),
      (List<HomeSectionModel> sections) => AsyncValue.data(sections),
    );
  }

  ({String platform, String lang, double? lat, double? lng})? _lastQuery;

  /// Repeats the last [getHomeSections], for a retry from a screen with no
  /// [HomeView] context to rebuild its arguments (the offers "View all" list).
  Future<void> reload() async {
    final q = _lastQuery;
    if (q == null) return;
    await getHomeSections(
      platform: q.platform,
      lang: q.lang,
      lat: q.lat,
      lng: q.lng,
    );
  }
}
