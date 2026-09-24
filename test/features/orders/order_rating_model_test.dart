import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_rating_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/rate_order_request_model.dart';

/// The `rating` block of `GET /my/orders/{uuid}` as `OrderRatingStateLookup`
/// renders it: one product already rated, one open, the store open, and no
/// courier ever assigned (`delivery: null`).
Map<String, dynamic> _sheet() => <String, dynamic>{
  'can_rate': true,
  'reason_code': null,
  'is_rated': true,
  'is_fully_rated': false,
  'products': <Map<String, dynamic>>[
    <String, dynamic>{
      'product_id': 5,
      'order_item_id': 11,
      'name': <String, String>{'ar': 'أ', 'en': 'A'},
      'image_url': null,
      'is_rated': true,
      'rating': <String, dynamic>{'id': 1, 'rate': 4, 'score': 4},
    },
    <String, dynamic>{
      'product_id': 6,
      'order_item_id': 12,
      'name': <String, String>{'ar': 'ب', 'en': 'B'},
      'image_url': null,
      'is_rated': false,
      'rating': null,
    },
  ],
  'vendor': <String, dynamic>{
    'vendor_id': 3,
    'name': 'Store',
    'logo_url': null,
    'is_rated': false,
    'rating': null,
  },
  'delivery': null,
};

void main() {
  test('only the targets still open are offered for rating', () {
    final OrderRatingModel rating = OrderRatingModel.fromJson(_sheet());

    expect(rating.isRated, isTrue);
    expect(
      rating.openProducts.map((RatedProductModel p) => p.productId),
      <int>[6],
    );
    expect(rating.isVendorOpen, isTrue);
    // No courier: nothing to demand stars for, and nothing to send.
    expect(rating.isDeliveryOpen, isFalse);
  });

  test('the request carries only what the screen offered', () {
    final OrderRatingModel rating = OrderRatingModel.fromJson(_sheet());

    final RateOrderRequest request = RateOrderRequest.build(
      orderId: 42,
      productIds: rating.openProducts
          .map((RatedProductModel p) => p.productId)
          .toList(),
      productRatings: <int>[5],
      productComments: <String>[''],
      vendorId: rating.isVendorOpen ? rating.vendor.id : null,
      vendorRating: 3,
      deliveryId: rating.isDeliveryOpen ? rating.delivery.id : null,
      deliveryRating: 5,
    );

    expect(request.toJson(), <String, dynamic>{
      'order_id': 42,
      'products': <Map<String, dynamic>>[
        <String, dynamic>{'product_id': 6, 'rate': 5, 'comment': null},
      ],
      'vendor': <String, dynamic>{'vendor_id': 3, 'rate': 3, 'comment': null},
    });
  });

  test('a closed, never-rated order has nothing to rate and nothing to show', () {
    final OrderRatingModel rating = OrderRatingModel.fromJson(<String, dynamic>{
      ..._sheet(),
      'can_rate': false,
      'reason_code': 'order_not_delivered',
      'is_rated': false,
    });

    expect(rating.canRate, isFalse);
    expect(rating.isRated, isFalse);
  });

  test('no rating block offers no rating', () {
    expect(OrderRatingModel.fromJson(null).canRate, isFalse);
  });
}
