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
  String routeId,
  bool isProduct,
});

final lastSearchResultsCacheProvider = Provider.autoDispose(
  (ref) => const LastSearchResultsCache(),
);

final lastSearchResultsProvider =
    StreamProvider.autoDispose<List<LastSearchCard>>(
      (ref) => ref.watch(lastSearchResultsCacheProvider).watch(),
    );

class LastSearchResultsCache {
  const LastSearchResultsCache();

  static const _key = HiveKeys.lastSearchResults;
  static const _maxCards = 10;

  Stream<List<LastSearchCard>> watch() => Stream.multi((controller) {
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

  Future<void> saveProduct(ProductModel product) async {
    final slug = product.slug;
    if (slug == null || slug.isEmpty) return;
    await _save(
      _card(product.name, product.images?.firstOrNull, slug, isProduct: true),
    );
  }

  Future<void> saveStore(StoreModel store) async {
    final id = store.id;
    if (id == null) return;
    await _save(
      _card(
        store.name,
        store.logoUrl ?? store.coverUrl,
        id.toString(),
        isProduct: false,
      ),
    );
  }

  Future<void> _save(LastSearchCard card) async {
    try {
      final box = HiveManager.box(HiveBoxes.recentSearches);
      List<LastSearchCard> cached = [];
      try {
        cached = _decode(box.get(_key));
      } catch (_) {
        // A new selection can replace a damaged snapshot.
      }
      final results = [
        card,
        ...cached.where((item) => !_sameResult(item, card)),
      ].take(_maxCards);
      await box.put(_key, _encode(results));
    } catch (_) {
      // Search results remain available even when local storage fails.
    }
  }

  Future<void> remove(LastSearchCard card) async {
    try {
      final box = HiveManager.box(HiveBoxes.recentSearches);
      final cached = _decode(box.get(_key));
      cached.removeWhere((item) => _sameResult(item, card));
      await box.put(_key, _encode(cached));
    } catch (_) {
      // Keep the last readable snapshot if the cache cannot be edited.
    }
  }

  static bool _sameResult(LastSearchCard a, LastSearchCard b) =>
      a.isProduct == b.isProduct && a.routeId == b.routeId;

  static LastSearchCard _card(
    Map<String, dynamic>? name,
    String? imageUrl,
    String routeId, {
    required bool isProduct,
  }) => (
    en: name?['en']?.toString(),
    ar: name?['ar']?.toString(),
    imageUrl: imageUrl ?? '',
    routeId: routeId,
    isProduct: isProduct,
  );

  static String _encode(Iterable<LastSearchCard> cards) => jsonEncode([
    for (final card in cards)
      {
        'en': card.en,
        'ar': card.ar,
        'imageUrl': card.imageUrl,
        'routeId': card.routeId,
        'isProduct': card.isProduct,
      },
  ]);

  static List<LastSearchCard> _decode(dynamic payload) {
    if (payload == null) return [];
    final json = jsonDecode(payload as String);
    // Older snapshots stored automatically fetched results.
    if (json is Map<String, dynamic>) return [];
    return [
      for (final item in (json as List<dynamic>).take(_maxCards))
        _card(
          item as Map<String, dynamic>,
          item['imageUrl'] as String?,
          item['routeId'] as String,
          isProduct: item['isProduct'] as bool,
        ),
    ];
  }
}
