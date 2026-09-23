import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/repo/checkout_repo.dart';



























final checkoutProvider =
    StateNotifierProvider<CheckoutViewModel, AsyncValue<CheckoutModel?>>(
      (Ref ref) => CheckoutViewModel(),
    );

class CheckoutViewModel extends StateNotifier<AsyncValue<CheckoutModel?>> {
  CheckoutViewModel() : super(const AsyncValue<CheckoutModel?>.data(null));

  final CheckoutRepo _repo = CheckoutRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  /// Prices the checkout of [vendorId] — `null` for every store in the cart.
  Future<String?> checkout({int? vendorId}) async {
    state = const AsyncValue<CheckoutModel?>.loading();

    final result = await _repo.preview(vendorId: vendorId);

    if (!mounted) return null;

    return result.fold(
      (Failure failure) {
        state = AsyncValue<CheckoutModel?>.error(
          failure.message,
          StackTrace.current,
        );
        return failure.message;
      },
      (CheckoutModel draft) {
        state = AsyncValue<CheckoutModel?>.data(draft);
        return null;
      },
    );
  }
}
