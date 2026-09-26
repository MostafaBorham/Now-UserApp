import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/repo/orders_repo.dart';

/// `data` of GET /api/v1/ratings/orders/last-delivered, shaped as
/// LastDeliveredRatingStatusResource + OrderRatingTargetsPresenter build it.
Map<String, dynamic> _payload({
  bool hasPendingRating = true,
  Map<String, dynamic>? delivery,
}) => <String, dynamic>{
  'has_pending_rating': hasPendingRating,
  'last_delivered_order': <String, dynamic>{
    'id': 41,
    'uuid': 'b1c2',
    'order_number': 'ORD-41',
    'status': 'delivered',
    'delivered_at': '2026-09-25T12:00:00.000000Z',
    'is_rated': false,
    'is_fully_rated': false,
    'can_rate': true,
    'reason_code': null,
    'pending_targets_count': 3,
    'products': <Map<String, dynamic>>[
      <String, dynamic>{
        'product_id': 5,
        'order_item_id': 90,
        'name': <String, dynamic>{'en': 'Tea', 'ar': 'شاي'},
        'image_url': 'https://x/tea.png',
        'quantity': 2,
        'can_rate': true,
        'is_rated': false,
        'rating': null,
      },
      <String, dynamic>{
        'product_id': 6,
        'order_item_id': 91,
        'name': <String, dynamic>{'en': 'Milk', 'ar': 'حليب'},
        'image_url': null,
        'quantity': 1,
        'can_rate': false,
        'is_rated': true,
        'rating': <String, dynamic>{'id': 7, 'rate': 4, 'comment': 'ok'},
      },
    ],
    'vendor': <String, dynamic>{
      'vendor_id': 3,
      'name': <String, dynamic>{'en': 'Smart Buy', 'ar': 'الشراء الذكي'},
      'logo_url': 'https://x/logo.png',
      'can_rate': true,
      'is_rated': false,
      'rating': null,
    },
    'delivery': delivery,
  },
};

void main() {
  group('OrdersRepo.pendingRatingOrder', () {
    test('reads the top-level rating sheet as the order rating', () {
      final OrderModel order = OrdersRepo.pendingRatingOrder(_payload())!;

      expect(order.id, 41);
      expect(order.uuid, 'b1c2');
      expect(order.rating.canRate, isTrue);
      // Only what is still open is offered — the rated product is not.
      expect(order.rating.openProducts.map((p) => p.productId).toList(), <int>[
        5,
      ]);
      expect(order.rating.isVendorOpen, isTrue);
      expect(order.rating.vendor.name?['ar'], 'الشراء الذكي');
      expect(order.rating.vendor.imageUrl, 'https://x/logo.png');
    });

    test('no courier means no courier section', () {
      final OrderModel order = OrdersRepo.pendingRatingOrder(_payload())!;
      expect(order.rating.isDeliveryOpen, isFalse);

      final OrderModel withCourier = OrdersRepo.pendingRatingOrder(
        _payload(
          delivery: <String, dynamic>{
            'delivery_id': 9,
            'name': 'Sami',
            'image_url': null,
            'can_rate': true,
            'is_rated': false,
            'rating': null,
          },
        ),
      )!;
      expect(withCourier.rating.isDeliveryOpen, isTrue);
    });

    test('nothing to prompt about once nothing is pending', () {
      expect(
        OrdersRepo.pendingRatingOrder(_payload(hasPendingRating: false)),
        isNull,
      );
    });

    test('a partly rated order is not offered again: rating is one-shot', () {
      // The backend still reports it pending — the rest could be rated.
      final Map<String, dynamic> payload = _payload();
      (payload['last_delivered_order'] as Map<String, dynamic>)['is_rated'] =
          true;
      expect(OrdersRepo.pendingRatingOrder(payload), isNull);
    });

    test('a customer with no delivered order yet is not an error', () {
      expect(
        OrdersRepo.pendingRatingOrder(<String, dynamic>{
          'has_pending_rating': false,
          'last_delivered_order': null,
        }),
        isNull,
      );
      expect(OrdersRepo.pendingRatingOrder(null), isNull);
    });
  });
}
