import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The debounced product-search text for the category details screen's Products
/// tab. Empty means no search.
///
/// Lives in the screen's `ProviderScope` and auto-disposes with it, so the term
/// resets every time the screen is opened. Feeds the `searchKey` of
/// `getCategoryProductsProvider`, so changing it re-queries the products (a new
/// family member with its own pagination state, like the All Stores screen).
final categoryProductsSearchProvider =
    StateProvider.autoDispose<String>((Ref ref) => '');
