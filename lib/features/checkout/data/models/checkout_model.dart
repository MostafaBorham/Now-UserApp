import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';

/// Parsed representation of a checkout preview (`/api/v1/checkout/cart/preview`).
///
/// The endpoint is a stateless pricing preview: the response `data` carries a
/// `checkout` object with `vendor_groups` (one store each, with its products
/// and per-store summary) plus a group-level `summary`. There is no persisted
/// draft: placing prices the cart again from scratch.
///
/// [fromJson] receives the response `data` object and adapts that
/// `vendor_groups` shape onto [OrderGroupModel]/[OrderModel] — the shape the
/// checkout UI already renders — so each vendor group becomes one "order".
class CheckoutModel {
  final OrderGroupModel orderGroup;

  /// The customer's saved payment cards, carried by the preview under
  /// `checkout.payment_cards` (same shape as the wallet's cards). Empty when the
  /// customer has none — the checkout payment section then shows the add-card
  /// prompt instead of the card list.
  final List<CardPaymentModel> paymentCards;

  const CheckoutModel({
    this.orderGroup = const OrderGroupModel(),
    this.paymentCards = const <CardPaymentModel>[],
  });

  /// The card a card-payment should default to: the one the server marks
  /// `is_default`, else the first card. Resolved from the flag, not list
  /// position, so the app never charges whatever happens to sit first.
  static CardPaymentModel? resolveDefaultCard(List<CardPaymentModel> cards) {
    for (final CardPaymentModel card in cards) {
      if (card.isDefault ?? false) return card;
    }
    return cards.isEmpty ? null : cards.first;
  }

  static List<CardPaymentModel> _parseCards(Map<String, dynamic> checkout) {
    final List<dynamic> raw =
        (checkout['payment_cards'] as List?) ?? const <dynamic>[];
    // An expired card can't pay (the server never checks expiry, so it fails
    // at the gateway): offer only the usable ones, as the wallet does.
    return raw
        .map((dynamic e) => CardPaymentModel.fromJson(e as Map<String, dynamic>))
        .where((CardPaymentModel card) => card.isUsable)
        .toList();
  }

  factory CheckoutModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CheckoutModel();
    }

    final Map<String, dynamic> checkout =
        (json['checkout'] as Map<String, dynamic>?) ?? json;

    final List<dynamic> vendorGroups =
        (checkout['vendor_groups'] as List?) ?? const <dynamic>[];
    final Map<String, dynamic> summary =
        (checkout['summary'] as Map<String, dynamic>?) ?? const {};

    return CheckoutModel(
      orderGroup: OrderGroupModel.fromJson(<String, dynamic>{
        'currency': checkout['currency'],
        'subtotal': summary['subtotal'],
        'tax': summary['tax'],
        'delivery_fee': summary['delivery_fee'],
        'discount': summary['discount'],
        'driver_tip': summary['driver_tip'],
        'total': summary['total'],
        'orders': vendorGroups.map(_vendorGroupToOrderJson).toList(),
      }),
      paymentCards: _parseCards(checkout),
    );
  }

  /// Parses the single-store preview
  /// (`POST /api/v1/checkout/vendor/{vendorId}/preview`).
  ///
  /// That endpoint's `checkout` object describes a single store directly — one
  /// `vendor`, a top-level `products` list and a `summary` — with no
  /// `vendor_groups`. It is itself exactly one vendor group, so the whole
  /// `checkout` object is reshaped through [_vendorGroupToOrderJson] into the
  /// single [OrderModel] the checkout UI already renders, and the same summary
  /// doubles as the group total (one store ⇒ store total == group total).
  factory CheckoutModel.fromSingleStoreJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CheckoutModel();
    }

    final Map<String, dynamic> checkout =
        (json['checkout'] as Map<String, dynamic>?) ?? json;

    final Map<String, dynamic> summary =
        (checkout['summary'] as Map<String, dynamic>?) ?? const {};

    return CheckoutModel(
      orderGroup: OrderGroupModel.fromJson(<String, dynamic>{
        'currency': checkout['currency'],
        'subtotal': summary['subtotal'],
        'tax': summary['tax'],
        'delivery_fee': summary['delivery_fee'],
        'discount': summary['discount'],
        'driver_tip': summary['driver_tip'],
        'total': summary['total'],
        'orders': <dynamic>[_vendorGroupToOrderJson(checkout)],
      }),
      paymentCards: _parseCards(checkout),
    );
  }

  /// Reshapes one preview `vendor_group` into the JSON [OrderModel.fromJson]
  /// expects, so a single store's card renders from its products and summary.
  static Map<String, dynamic> _vendorGroupToOrderJson(dynamic group) {
    final Map<String, dynamic> g =
        (group as Map<String, dynamic>?) ?? const {};
    final Map<String, dynamic> vendor =
        (g['vendor'] as Map<String, dynamic>?) ?? const {};
    final Map<String, dynamic> summary =
        (g['summary'] as Map<String, dynamic>?) ?? const {};

    return <String, dynamic>{
      'vendor': vendor,
      'vendor_id': vendor['id'],
      'branch_id': g['branch_id'],
      'subtotal': summary['subtotal'],
      'tax': summary['tax'],
      'delivery_fee': summary['delivery_fee'],
      'discount': summary['discount'],
      'total': summary['total'],
      'items': ((g['products'] as List?) ?? const <dynamic>[]).map((dynamic p) {
        final Map<String, dynamic> item =
            (p as Map<String, dynamic>?) ?? const {};
        // OrderModel.fromJson remaps product_*/unit_price onto the product
        // schema, so hand it those keys from the preview's item shape.
        return <String, dynamic>{
          'product_id': item['product_id'],
          'product_name': item['name'],
          'product_sku': item['sku'],
          'unit_price': item['unit_price'],
          'quantity': item['quantity'],
          'image_url': item['image_url'],
        };
      }).toList(),
    };
  }
}

/// A preview's money, group-wide, and its per-store [orders].
///
/// Only what the preview carries: there is no placed-group state here (uuid,
/// status, payment) — the place response is parsed straight into the
/// [OrderModel]s it created.
class OrderGroupModel {
  final String? currency;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double discount;
  final double driverTip;
  final double total;
  final List<OrderModel> orders;

  const OrderGroupModel({
    this.currency,
    this.subtotal = 0,
    this.tax = 0,
    this.deliveryFee = 0,
    this.discount = 0,
    this.driverTip = 0,
    this.total = 0,
    this.orders = const <OrderModel>[],
  });

  factory OrderGroupModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OrderGroupModel();
    }

    return OrderGroupModel(
      currency: json['currency']?.toString(),
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '') ?? 0.0,
      tax: double.tryParse(json['tax']?.toString() ?? '') ?? 0.0,
      deliveryFee:
          double.tryParse(json['delivery_fee']?.toString() ?? '') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '') ?? 0.0,
      driverTip: double.tryParse(json['driver_tip']?.toString() ?? '') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '') ?? 0.0,
      orders:
          (json['orders'] as List?)
              ?.map((e) => OrderModel.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          const <OrderModel>[],
    );
  }
}
