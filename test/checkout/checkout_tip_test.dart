import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/driver_tip_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/wallet_payment_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';

// The tip is added by the app instead of re-priced by the server. That holds
// only while the app adds it exactly as the server does
// (`PerVendorPricingService::calculate`): once, to the group total, and to
// nothing else. These previews are shaped like the server's, priced with no
// tip, as the app now always asks for them.

/// One store's `summary`: SAR 100 + 15% VAT + SAR 25 delivery, as in the
/// backend's own tip test.
Map<String, dynamic> _storeSummary({String discount = '0.00'}) =>
    <String, dynamic>{
      'subtotal': '100.00',
      'discount': discount,
      'tax': '15.00',
      'delivery_fee': '25.00',
      'total': '140.00',
    };

Map<String, dynamic> _vendorGroup(int id) => <String, dynamic>{
  'vendor': <String, dynamic>{'id': id},
  'products': <dynamic>[],
  'summary': _storeSummary(),
};

/// `POST /checkout/cart/preview` for two stores (`CartCheckoutResource`).
final Map<String, dynamic> _cartPreview = <String, dynamic>{
  'checkout': <String, dynamic>{
    'vendor_groups': <dynamic>[_vendorGroup(1), _vendorGroup(2)],
    'summary': <String, dynamic>{
      'subtotal': '200.00',
      'discount': '0.00',
      'tax': '30.00',
      'delivery_fee': '50.00',
      'driver_tip': '0.00',
      'total': '280.00',
    },
  },
};

/// `POST /checkout/vendor/{id}/preview` (`VendorCheckoutResource`).
final Map<String, dynamic> _vendorPreview = <String, dynamic>{
  'checkout': <String, dynamic>{
    'vendor': <String, dynamic>{'id': 1},
    'products': <dynamic>[],
    'summary': <String, dynamic>{
      ..._storeSummary(),
      'driver_tip': '0.00',
      'total': '140.00',
    },
  },
};

class _PricedCheckout extends CheckoutViewModel {
  _PricedCheckout(CheckoutModel checkout) {
    state = AsyncValue<CheckoutModel?>.data(checkout);
  }
}

void main() {
  test('one store: the tip is added to the total and to nothing else', () {
    final OrderGroupModel group = CheckoutModel.fromSingleStoreJson(
      _vendorPreview,
    ).withTip(10).orderGroup;

    expect(group.total, 150);
    expect(group.driverTip, 10);
    expect(group.subtotal, 100);
    expect(group.tax, 15);
    expect(group.deliveryFee, 25);
    expect(group.discount, 0);
    expect(group.orders.single.total, 140);
  });

  test(
    'several stores: the tip is added once, to the group, not per store',
    () {
      final OrderGroupModel group = CheckoutModel.fromJson(
        _cartPreview,
      ).withTip(7.5).orderGroup;

      // The backend's invariant: group total = the store totals + the tip.
      expect(group.total, 287.5);
      expect(group.driverTip, 7.5);
      expect(group.tax, 30);
      expect(group.orders.map((o) => o.total), <double>[140, 140]);
    },
  );

  test('a new tip replaces the old one, and none takes it all back', () {
    // A preview priced with a tip (only an old app sent one) is swapped too.
    const OrderGroupModel priced = OrderGroupModel(driverTip: 5, total: 128.45);

    expect(priced.withTip(7).total, 130.45);
    expect(priced.withTip(7).withTip(0).total, 123.45);
    expect(priced.withTip(0).driverTip, 0);
  });

  test('the total is summed in halalas, never off by a double cent', () {
    // 0.1 + 0.2 in doubles is 0.30000000000000004.
    expect(const OrderGroupModel(total: 0.1).withTip(0.2).total, 0.3);
    expect(const OrderGroupModel(total: 123.45).withTip(1000).total, 1123.45);
  });

  test('an unchanged tip keeps the same model, so nothing rebuilds', () {
    final CheckoutModel checkout = CheckoutModel.fromJson(_cartPreview);
    expect(identical(checkout.withTip(0), checkout), isTrue);
  });

  test('the invoice and the wallet see the picked tip without a re-price', () {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        checkoutProvider.overrideWith(
          (Ref ref) => _PricedCheckout(CheckoutModel.fromJson(_cartPreview)),
        ),
      ],
    );
    addTearDown(container.dispose);
    // The screen keeps these alive the same way.
    container.listen(driverTipProvider, (_, _) {});
    container.listen(tippedCheckoutProvider, (_, _) {});

    expect(container.read(checkoutTotalProvider), 280);

    container.read(driverTipProvider.notifier).state = 5;

    expect(container.read(tippedCheckoutProvider)!.orderGroup.total, 285);
    expect(container.read(tippedCheckoutProvider)!.orderGroup.driverTip, 5);
    expect(container.read(checkoutTotalProvider), 285);
    // The server's pricing itself is untouched: no request, no loading.
    expect(container.read(checkoutProvider).isLoading, isFalse);
    expect(container.read(checkoutProvider).value!.orderGroup.total, 280);
  });
}
