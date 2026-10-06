import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/repo/wallet_repo.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/default_payment_card_provider.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';

/// One-shot action: add or edit a payment card.
///
/// Nothing is requested when first watched — saving is a user action — so the
/// notifier starts idle (`AsyncValue.data(null)`) and a caller triggers it with
/// `addPaymentCard(...)` / `updatePaymentCard(...)`, watching the loading slice
/// to drive the submit-button spinner.
///
/// On a confirmed server success [getMyCardsProvider] is refetched — the same
/// refetch every card mutation goes through — so the saved card appears in the
/// list and [defaultPaymentCardProvider] follows. On failure nothing changes and
/// the message is returned so the caller can surface it.
final addPaymentCardProvider = StateNotifierProvider.autoDispose<
    AddPaymentCardViewModel, AsyncValue<void>>(
  (Ref ref) => AddPaymentCardViewModel(ref),
);

class AddPaymentCardViewModel extends StateNotifier<AsyncValue<void>> {
  AddPaymentCardViewModel(this._ref) : super(const AsyncValue<void>.data(null));

  final Ref _ref;
  final WalletRepo _repo = WalletRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  /// Saves a new card. [expiry] is the `MM/YY` string from the form.
  /// Returns `null` on success, or the error message on failure.
  ///
  /// This sends the raw card details the backend's test-card mode expects; the
  /// server derives the stored brand/last-four and persists neither the full
  /// number nor the CVC. When live (Moyasar) mode is turned on the request shape
  /// changes to a provider token instead — see `WalletEndpoints.addPaymentCardBody`.
  Future<String?> addPaymentCard({
    required String cardholderName,
    required String cardNumber,
    required String expiry,
    required String cvc,
    bool setAsDefault = false,
  }) async {
    final ({int month, int year}) parsed = parseExpiry(expiry);
    final String number = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (_isAlreadySaved(number, parsed)) return _alreadySaved();

    state = const AsyncValue<void>.loading();

    // The default travels with the card itself: one request, so there is no
    // second call to fail after the "card added" toast.
    final Either<Failure, CardPaymentModel> result = await _repo.addPaymentCard(
      cardholderName: cardholderName,
      cardNumber: number,
      expiryMonth: parsed.month,
      expiryYear: parsed.year,
      cvc: cvc,
      setDefault: setAsDefault,
    );

    if (!mounted) return null;
    return _finish(result, setAsDefault: false);
  }

  /// Updates the existing card [cardId]. A partial update: [cardNumber]/[cvc]
  /// are optional and sent only when re-entered (a saved card never exposes the
  /// full number or CVC to prefill). [cardholderName] and [expiry] are always
  /// sent (the edit form prefills them). Returns `null` on success, else the
  /// error message.
  Future<String?> updatePaymentCard({
    required int cardId,
    required String cardholderName,
    required String expiry,
    String? cardNumber,
    String? cvc,
    bool setAsDefault = false,
  }) async {
    final ({int month, int year}) parsed = parseExpiry(expiry);
    final String number = (cardNumber ?? '').replaceAll(RegExp(r'\D'), '');
    final String cvcValue = cvc?.trim() ?? '';
    if (number.isNotEmpty && _isAlreadySaved(number, parsed, except: cardId)) {
      return _alreadySaved();
    }

    state = const AsyncValue<void>.loading();

    final Either<Failure, CardPaymentModel> result =
        await _repo.updatePaymentCard(
      id: cardId,
      cardholderName: cardholderName,
      expiryMonth: parsed.month,
      expiryYear: parsed.year,
      cardNumber: number.isEmpty ? null : number,
      cvc: cvcValue.isEmpty ? null : cvcValue,
    );

    if (!mounted) return null;
    return _finish(result, setAsDefault: setAsDefault);
  }

  /// Whether another loaded card has the same last four digits and expiry —
  /// the same card saved twice (BUG-014, QA V2). Caught here for instant
  /// feedback; the backend is asked to refuse it too (only it sees every
  /// card, and the list may not be loaded). [except] is the card being edited.
  bool _isAlreadySaved(
    String number,
    ({int month, int year}) expiry, {
    int? except,
  }) => isAlreadySaved(
    _ref.read(getMyCardsProvider).valueOrNull ?? const <CardPaymentModel>[],
    number,
    expiry,
    except: except,
  );

  /// The rule behind [_isAlreadySaved], over [cards].
  @visibleForTesting
  static bool isAlreadySaved(
    List<CardPaymentModel> cards,
    String number,
    ({int month, int year}) expiry, {
    int? except,
  }) {
    if (number.length < 4) return false;
    final String lastFour = number.substring(number.length - 4);
    return cards.any(
      (CardPaymentModel card) =>
          card.id != except &&
          card.lastFour == lastFour &&
          card.expiryMonth == expiry.month &&
          (card.expiryYear ?? -1) % 100 == expiry.year % 100,
    );
  }

  String _alreadySaved() {
    state = AsyncValue<void>.error(
      LangKeys.cardAlreadySavedKey,
      StackTrace.current,
    );
    return LangKeys.cardAlreadySavedKey;
  }

  /// Shared success/failure handling for add and update. [setAsDefault] asks
  /// for a follow-up promotion (the edit path; an add sends it in its body).
  String? _finish(
    Either<Failure, CardPaymentModel> result, {
    required bool setAsDefault,
  }) {
    return result.fold(
      (Failure failure) {
        state = AsyncValue<void>.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (CardPaymentModel card) {
        state = const AsyncValue<void>.data(null);
        final int? id = card.id;
        // The server made this card the default: the default provider keeps its
        // held card across a refetch, so it has to be told.
        if (card.isDefault == true) {
          _ref.read(defaultPaymentCardProvider.notifier).adopt(card);
        }
        if (setAsDefault && id != null && card.isDefault != true) {
          // Promote the saved card through the dedicated set-default endpoint
          // (the backend auto-defaults only the first card, so a later card the
          // customer wants as default has to be promoted). That call updates the
          // default provider and refetches the cards list itself — on success
          // only, so a failed promotion refetches here, or the list would miss
          // the edit that did save. The notifier is read up front because this
          // view model may be gone by the time the promotion settles.
          final GetMyCardsViewModel myCards = _ref.read(
            getMyCardsProvider.notifier,
          );
          _ref
              .read(defaultPaymentCardProvider.notifier)
              .setPaymentCardDefault(id)
              .then((String? error) {
                if (error != null) myCards.getMyCards();
              });
        } else {
          // Confirmed by the server: refetch so the saved card lands in the list
          // (and the default provider following it), straight from the repo.
          _ref.read(getMyCardsProvider.notifier).getMyCards();
        }
        return null;
      },
    );
  }

  /// Splits an `MM/YY` (or `MMYY`) expiry into a month and the full year — e.g.
  /// `12/35` → `(month: 12, year: 2035)`. The form validator guarantees the
  /// shape before this runs; missing digits fall back to zero so the backend's
  /// own range checks reject an obviously-bad value rather than the app crashing.
  static ({int month, int year}) parseExpiry(String raw) {
    final String digits = raw.replaceAll(RegExp(r'\D'), '').padRight(4, '0');
    final int month = int.tryParse(digits.substring(0, 2)) ?? 0;
    final int year = 2000 + (int.tryParse(digits.substring(2, 4)) ?? 0);
    return (month: month, year: year);
  }
}
