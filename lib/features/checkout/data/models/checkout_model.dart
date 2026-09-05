import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';

/// Parsed representation of a checkout preview (`/api/v1/checkout/cart/preview`).
///
/// The endpoint is a stateless pricing preview: the response `data` carries a
/// `checkout` object with `vendor_groups` (one store each, with its products
/// and per-store summary) plus a group-level `summary`. There is no persisted
/// draft and no `order_group`/`uuid`.
///
/// [fromJson] receives the response `data` object and adapts that
/// `vendor_groups` shape onto [OrderGroupModel]/[OrderModel] — the shape the
/// checkout UI already renders — so each vendor group becomes one "order".
class CheckoutModel {
  final OrderGroupModel orderGroup;

  const CheckoutModel({this.orderGroup = const OrderGroupModel()});

  factory CheckoutModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CheckoutModel();
    }

    // Older builds nested the payload under `order_group`; the live backend
    // nests it under `checkout`. Fall back to `json` itself so a future
    // un-nested response still parses.
    final Map<String, dynamic> checkout =
        (json['checkout'] as Map<String, dynamic>?) ??
        (json['order_group'] as Map<String, dynamic>?) ??
        json;

    final List<dynamic> vendorGroups =
        (checkout['vendor_groups'] as List?) ??
        (checkout['orders'] as List?) ??
        const <dynamic>[];
    final Map<String, dynamic> summary =
        (checkout['summary'] as Map<String, dynamic>?) ?? const {};
    final Map<String, dynamic>? address =
        checkout['address'] as Map<String, dynamic>?;

    return CheckoutModel(
      orderGroup: OrderGroupModel.fromJson(<String, dynamic>{
        'currency': checkout['currency'],
        'subtotal': summary['subtotal'],
        'tax': summary['tax'],
        'delivery_fee': summary['delivery_fee'],
        'discount': summary['discount'],
        'driver_tip': summary['driver_tip'],
        'total': summary['total'],
        'address_id': address?['id'],
        'delivery_address': address?['full_address'],
        'coupons': checkout['coupons'],
        'orders': vendorGroups.map(_vendorGroupToOrderJson).toList(),
      }),
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

class OrderGroupModel {
  final String? uuid;
  final String? groupNumber;
  final bool isDraft;
  final String? confirmedAt;
  final String? paymentStatus;
  final String? derivedStatus;
  final String? currency;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double discount;
  final double driverTip;
  final double total;
  final String? paymentMethod;
  final int? addressId;
  final String? deliveryAddress;
  final String? deliveryInstructions;
  final String? notes;
  final String? placedAt;
  final String? createdAt;
  final List<OrderModel> orders;
  final List<CouponModel> coupons;

  const OrderGroupModel({
    this.uuid,
    this.groupNumber,
    this.isDraft = false,
    this.confirmedAt,
    this.paymentStatus,
    this.derivedStatus,
    this.currency,
    this.subtotal = 0,
    this.tax = 0,
    this.deliveryFee = 0,
    this.discount = 0,
    this.driverTip = 0,
    this.total = 0,
    this.paymentMethod,
    this.addressId,
    this.deliveryAddress,
    this.deliveryInstructions,
    this.notes,
    this.placedAt,
    this.createdAt,
    this.orders = const <OrderModel>[],
    this.coupons = const <CouponModel>[],
  });

  factory OrderGroupModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OrderGroupModel();
    }

    return OrderGroupModel(
      uuid: json['uuid']?.toString(),
      groupNumber: json['group_number']?.toString(),
      isDraft: json['is_draft'] as bool? ?? false,
      confirmedAt: json['confirmed_at']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      derivedStatus: json['derived_status']?.toString(),
      currency: json['currency']?.toString(),
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '') ?? 0.0,
      tax: double.tryParse(json['tax']?.toString() ?? '') ?? 0.0,
      deliveryFee:
          double.tryParse(json['delivery_fee']?.toString() ?? '') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '') ?? 0.0,
      driverTip: double.tryParse(json['driver_tip']?.toString() ?? '') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '') ?? 0.0,
      paymentMethod: json['payment_method']?.toString(),
      addressId: (json['address_id'] as num?)?.toInt(),
      deliveryAddress: json['delivery_address']?.toString(),
      deliveryInstructions: json['delivery_instructions']?.toString(),
      notes: json['notes']?.toString(),
      placedAt: json['placed_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      orders:
          (json['orders'] as List?)
              ?.map((e) => OrderModel.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          const <OrderModel>[],
      coupons:
          (json['coupons'] as List?)
              ?.map((e) => CouponModel.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          const <CouponModel>[],
    );
  }
}

class CouponModel {
  final int? vendorId;
  final String? code;
  final bool applied;
  final String? reason;

  const CouponModel({
    this.vendorId,
    this.code,
    this.applied = false,
    this.reason,
  });

  factory CouponModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CouponModel();
    }

    return CouponModel(
      vendorId: (json['vendor_id'] as num?)?.toInt(),
      code: json['code']?.toString(),
      applied: json['applied'] as bool? ?? false,
      reason: json['reason']?.toString(),
    );
  }
}
