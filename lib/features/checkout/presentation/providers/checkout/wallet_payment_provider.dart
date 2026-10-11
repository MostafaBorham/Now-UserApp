import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_info_vm.dart';

/// The customer's own tick on the wallet row, or `null` until they make one.
///
/// autoDispose, kept alive by the wallet row, so every checkout starts back on
/// the smart default (see [walletUseProvider]).
final walletPaymentProvider = StateProvider.autoDispose<bool?>(
  (Ref ref) => null,
);

/// What the wallet does for this checkout.
enum WalletUse {
  /// Unticked: the picked card pays.
  off,

  /// Ticked and able to pay (or the balance is unknown: the server decides).
  pays,

  /// Ticked, but the balance can't cover the total. There is no split payment,
  /// so the order waits for a top-up or for the wallet to be unticked.
  short,
}

/// The customer's tick always wins. Until they make one, the wallet starts
/// ticked only once the balance and the total are both known and the balance
/// covers it — so a short or unknown wallet never starts out blocking the
/// order.
final walletUseProvider = Provider.autoDispose<WalletUse>((Ref ref) {
  final WalletModel? wallet = ref.watch(getWalletInfoProvider).valueOrNull;
  final double? total = ref.watch(checkoutTotalProvider);
  final bool short = walletFallsShort(wallet, total);
  final bool ticked =
      ref.watch(walletPaymentProvider) ??
      (_halalas(wallet) != null && total != null && !short);
  if (!ticked) return WalletUse.off;
  return short ? WalletUse.short : WalletUse.pays;
});

int? _halalas(WalletModel? wallet) {
  final double? balance = wallet?.balance;
  return wallet?.balanceHalalas ??
      (balance == null ? null : sarDoubleToHalalas(balance));
}

/// Whether [wallet] can't pay [total] on its own. `false` while either is
/// unknown: the server decides.
bool walletFallsShort(WalletModel? wallet, double? total) =>
    walletShortfallHalalas(wallet, total) != null;

/// How far [wallet] falls short of [total], in halalas; `null` when it covers
/// it or either is unknown.
int? walletShortfallHalalas(WalletModel? wallet, double? total) {
  final int? halalas = _halalas(wallet);
  if (halalas == null || total == null) return null;
  final int shortfall = sarDoubleToHalalas(total) - halalas;
  return shortfall > 0 ? shortfall : null;
}

/// The checkout total, `null` until the checkout loads.
final checkoutTotalProvider = Provider.autoDispose<double?>(
  (Ref ref) => ref.watch(
    checkoutProvider.select(
      (AsyncValue<CheckoutModel?> state) => state.valueOrNull?.orderGroup.total,
    ),
  ),
);
