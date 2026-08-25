import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The debounced store-search text for the category details screen's Stores
/// tab. Empty means no search.
///
/// Lives in the screen's `ProviderScope` and auto-disposes with it, so the term
/// resets every time the screen is opened. Feeds the `searchKey` of
/// `getCategoryStoresProvider`, so changing it re-queries the stores (a new
/// family member with its own pagination state, like the All Stores screen).
final categoryStoresSearchProvider =
    StateProvider.autoDispose<String>((Ref ref) => '');
