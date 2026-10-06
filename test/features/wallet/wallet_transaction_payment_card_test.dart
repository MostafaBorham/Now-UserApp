import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/wallet_history_item.dart';

import '../../helpers/categories_test_harness.dart';

/// BUG-013 (QA V2): a top-up row names the card it was charged to, once the
/// backend sends `payment_card` (requested); rows without it are unchanged.
void main() {
  setUpAll(initCategoriesTestLocalization);

  const Map<String, dynamic> topUp = <String, dynamic>{
    'id': 1,
    'title': 'Wallet top-up',
    'display_status': 'successful',
    'amount_label': '50.00',
    'payment_card': <String, dynamic>{'brand': 'visa', 'last_four': '4242'},
  };

  test('parses payment_card and survives the cache round-trip', () {
    final WalletTransactionModel model = WalletTransactionModel.fromJson(topUp);

    expect(model.paymentCard, (brand: 'visa', lastFour: '4242'));
    expect(WalletTransactionModel.fromJson(model.toJson()), model);
  });

  test('no payment_card is null, as before the backend change', () {
    final WalletTransactionModel model = WalletTransactionModel.fromJson(
      <String, dynamic>{...topUp}..remove('payment_card'),
    );

    expect(model.paymentCard, isNull);
  });

  testWidgets('the row shows the brand and last four', (tester) async {
    await pumpCategoriesWidget(
      tester,
      WalletHistoryItem(transaction: WalletTransactionModel.fromJson(topUp)),
    );

    expect(find.text('Visa •••• 4242'), findsOneWidget);
  });
}
