import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

typedef LastSearchCard = ({
  String? en,
  String? ar,
  String imageUrl,
  String? routeId,
});
typedef LastSearchResults = ({
  List<LastSearchCard> products,
  List<LastSearchCard> stores,
});

final lastSearchResultsCacheProvider = Provider.autoDispose(
  (ref) => const LastSearchResultsCache(),
);

final lastSearchResultsProvider = StreamProvider.autoDispose<LastSearchResults>(
  (ref) => ref.watch(lastSearchResultsCacheProvider).watch(),
);

class LastSearchResultsCache {
  const LastSearchResultsCache();

  static const _key = HiveKeys.lastSearchResults;
  static const _maxCardsPerType = 5;

  Stream<LastSearchResults> watch() => Stream.multi((controller) {
    try {
      final box = HiveManager.box(HiveBoxes.recentSearches);
      void emit() {
        try {
          controller.add(_decode(box.get(_key)));
        } catch (error, stack) {
          controller.addError(error, stack);
        }
      }

      final subscription = box.watch(key: _key).listen((_) => emit());
      controller.onCancel = subscription.cancel;
      emit();
    } catch (error, stack) {
      controller.addError(error, stack);
      controller.close();
    }
  });

  Future<void> save(
    List<ProductModel> products,
    List<StoreModel> stores,
  ) async {
    if (products.isEmpty && stores.isEmpty) return;

    LastSearchResults cached = (products: [], stores: []);
    try {
      cached = _decode(HiveManager.box(HiveBoxes.recentSearches).get(_key));
    } catch (_) {
      // A successful search can replace a damaged snapshot.
    }
    await _write((
      products: _prepend(
        products.map(
          (product) =>
              _card(product.name, product.images?.firstOrNull, product.slug),
        ),
        cached.products,
      ),
      stores: _prepend(
        stores.map(
          (store) => _card(
            store.name,
            store.logoUrl ?? store.coverUrl,
            store.id?.toString(),
          ),
        ),
        cached.stores,
      ),
    ));
  }

  static List<LastSearchCard> _prepend(
    Iterable<LastSearchCard> newest,
    List<LastSearchCard> cached,
  ) {
    final seenIds = <String>{};
    final seenCards = <(String?, String?, String)>{};
    return newest
        .followedBy(cached)
        .where((card) {
          final newAppearance = seenCards.add((
            card.en,
            card.ar,
            card.imageUrl,
          ));
          final id = card.routeId;
          return id == null ? newAppearance : seenIds.add(id);
        })
        .take(_maxCardsPerType)
        .toList();
  }

  Future<void> remove(LastSearchCard card, {required bool isProduct}) async {
    try {
      final box = HiveManager.box(HiveBoxes.recentSearches);
      final results = _decode(box.get(_key));
      final items = isProduct ? results.products : results.stores;
      if (items.remove(card)) await _write(results);
    } catch (_) {
      // Keep the last readable snapshot if the cache cannot be edited.
    }
  }

  Future<void> _write(LastSearchResults results) async {
    try {
      final box = HiveManager.box(HiveBoxes.recentSearches);
      await box.put(
        _key,
        jsonEncode({
          'products': results.products.map(_encodeCard).toList(),
          'stores': results.stores.map(_encodeCard).toList(),
        }),
      );
    } catch (_) {
      // Search results remain available even when local storage fails.
    }
  }

  static LastSearchCard _card(
    Map<String, dynamic>? name,
    String? imageUrl,
    String? routeId,
  ) => (
    en: name?['en']?.toString(),
    ar: name?['ar']?.toString(),
    imageUrl: imageUrl ?? '',
    routeId: routeId?.isNotEmpty == true ? routeId : null,
  );

  static Map<String, dynamic> _encodeCard(LastSearchCard card) => {
    'en': card.en,
    'ar': card.ar,
    'imageUrl': card.imageUrl,
    'routeId': card.routeId,
  };

  static LastSearchResults _decode(dynamic payload) {
    if (payload == null) return (products: [], stores: []);
    final json = jsonDecode(payload as String) as Map<String, dynamic>;
    List<LastSearchCard> decodeList(String key) => [
      for (final item in (json[key] as List<dynamic>).take(_maxCardsPerType))
        _card(
          item as Map<String, dynamic>,
          item['imageUrl'] as String?,
          item['routeId'] as String?,
        ),
    ];
    return (products: decodeList('products'), stores: decodeList('stores'));
  }
}
