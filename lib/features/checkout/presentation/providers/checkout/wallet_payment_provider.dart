import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the wallet pays for this checkout. On by default — the wallet is the
/// preselected payment method, and any method picked above it only covers the
/// shortfall when the balance falls short of the total.
///
/// Kept alive by [WalletPaymentOption] watching it and disposed with the
/// screen, so every checkout starts with the wallet enabled again.
final walletPaymentProvider = StateProvider.autoDispose<bool>(
  (Ref ref) => true,
);
