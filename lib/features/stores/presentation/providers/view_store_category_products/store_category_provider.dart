import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';

/// The store category whose products are being viewed.
///
/// Always overridden with the [CategoryModel] passed to
/// `ViewStoreCategoryProductsScreen` via a `ProviderScope`; reading it
/// without the override is a programming error.
final storeCategoryProvider = Provider.autoDispose<CategoryModel>((ref) {
  throw UnimplementedError();
});
