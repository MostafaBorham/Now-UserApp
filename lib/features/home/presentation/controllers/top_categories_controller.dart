import 'package:flutter_riverpod/flutter_riverpod.dart';

final topCategoriesCountProvider = Provider.autoDispose<int>(
  (ref) => 4,
);

/// Index of the top-category item currently visible in the carousel.
final currentTopCategoryIndexProvider = StateProvider.autoDispose<int>(
  (ref) => 0,
);
