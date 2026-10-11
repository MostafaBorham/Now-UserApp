import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/wallet_payment_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_info_vm.dart';

class _PricedCheckout extends CheckoutViewModel {
  _PricedCheckout(double? total) {
    if (total != null) {
      state = AsyncValue<CheckoutModel?>.data(
        CheckoutModel(orderGroup: OrderGroupModel(total: total)),
      );
    }
  }
}

// BUG-036/044: the wallet used to start ticked whatever the balance, and the
// card radio kept a selection the order never used.
void main() {
  WalletUse use({double? total, int? balance, bool? choice}) {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        checkoutProvider.overrideWith((Ref ref) => _PricedCheckout(total)),
        getWalletInfoProvider.overrideWith(
          (Ref ref) => balance == null
              ? GetWalletInfoViewModel()
              : (GetWalletInfoViewModel()
                  ..setWallet(WalletModel(balanceHalalas: balance))),
        ),
        walletPaymentProvider.overrideWith((Ref ref) => choice),
      ],
    );
    addTearDown(container.dispose);
    return container.read(walletUseProvider);
  }

  test('starts ticked only when the balance covers the total', () {
    expect(use(total: 50, balance: 5000), WalletUse.pays);
    expect(use(total: 50, balance: 4999), WalletUse.off);
  });

  test('starts unticked while the balance or the total is unknown', () {
    expect(use(total: 50), WalletUse.off);
    expect(use(balance: 5000), WalletUse.off);
  });

  test("the customer's tick always wins", () {
    expect(use(total: 50, balance: 5000, choice: false), WalletUse.off);
    expect(use(total: 50, balance: 1000, choice: true), WalletUse.short);
    expect(use(total: 50, choice: true), WalletUse.pays);
  });
}
