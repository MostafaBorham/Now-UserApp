import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The id of the store whose category products are being viewed.
///
/// Always overridden with the store id passed to
/// `ViewStoreCategoryProductsScreen` via a `ProviderScope`; reading it
/// without the override is a programming error.
final storeIdProvider = Provider.autoDispose<int>((ref) {
  throw UnimplementedError();
});
