import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/repo/wallet_repo.dart';

/// Single task: hold the customer's saved payment cards, shared across the app
/// (the my-cards sheet, the add-balance card picker, ...).
///
/// Deliberately **not** `autoDispose` and it does **not** fetch on creation: it
/// is the session orchestrator that fires [getMyCards] once when a user session
/// resolves (see `AuthSessionViewModel`) and invalidates it on logout, exactly
/// like the other user dependencies. The endpoint returns every card in one
/// un-paginated shot, so the state is a plain `List` (no pagination). Screens
/// only `ref.watch(getMyCardsProvider)` and render the [AsyncValue]; retry with
/// `ref.read(getMyCardsProvider.notifier).getMyCards()`.
final getMyCardsProvider = StateNotifierProvider<GetMyCardsViewModel,
    AsyncValue<List<CardPaymentModel>>>(
  (Ref ref) => GetMyCardsViewModel(),
);

class GetMyCardsViewModel
    extends StateNotifier<AsyncValue<List<CardPaymentModel>>> {
  GetMyCardsViewModel() : super(const AsyncValue.loading());

  final WalletRepo _repo = WalletRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getMyCards() async {
    // Always pass through the loading state and reload fresh in the server's
    // own order — the first login load, a retry, and every mutation-driven
    // refetch alike. A card mutation (delete / set-default) runs under the
    // my-cards sheet's blocking overlay; the moment that overlay lifts on
    // success this refetch flips the list to `loading`, so the sheet refreshes
    // visibly through the shimmer before the updated cards land.
    state = const AsyncValue.loading();

    final result = await _repo.getMyCards();

    if (!mounted) return;

    result.fold(
      (Failure failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (List<CardPaymentModel> cards) => state = AsyncValue.data(cards),
    );
  }
}
