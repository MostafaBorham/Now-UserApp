import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/cart/data/repo/cart_repo.dart';

/// One-shot action: remove a single cart line.
///
/// Keyed by `productId` so each product's deletion is tracked independently and
/// resets automatically once the widget watching it disposes (autoDispose).
///
/// State semantics on `AsyncValue<bool>`:
/// - `AsyncData(false)`  → idle, nothing requested yet (initial),
/// - `AsyncLoading`      → request in flight,
/// - `AsyncData(true)`   → removed successfully,
/// - `AsyncError`        → failed; carries the user-facing message.
final deleteCartProductProvider = StateNotifierProvider.autoDispose
    .family<DeleteCartProductViewModel, AsyncValue<bool>, int>(
  (Ref ref, int productId) => DeleteCartProductViewModel(productId),
);

class DeleteCartProductViewModel extends StateNotifier<AsyncValue<bool>> {
  DeleteCartProductViewModel(this._productId)
      : super(const AsyncValue<bool>.data(false));

  final int _productId;
  final CartRepo _repo = CartRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> deleteCartItem() async {
    state = const AsyncValue<bool>.loading();

    final Either<Failure, String> result =
        await _repo.deleteCartProduct(_productId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue<bool>.error(failure.message, StackTrace.current),
      (String _) => const AsyncValue<bool>.data(true),
    );
  }
}
