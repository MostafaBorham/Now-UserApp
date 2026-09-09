import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the featured store currently visible in the carousel. Watched only
/// by the page-indicator dots, so a page change repaints nothing else.
final currentFeaturedStoreIndexProvider = StateProvider.autoDispose<int>(
  (ref) => 0,
);
