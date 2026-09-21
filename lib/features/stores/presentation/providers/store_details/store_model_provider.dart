import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';

/// The store the details screen is showing, handed to its widgets through a
/// `ProviderScope` override so none of them has to be passed the model.
///
/// Reading it outside that scope is a programming error, not a runtime state —
/// hence the throw, with a message saying which override is missing.
final storeProvider = Provider.autoDispose<StoreModel>((ref) {
  throw UnimplementedError(
    'storeProvider must be overridden with the store being shown — see the '
    'ProviderScope in StoreDetailsScreen.',
  );
});
