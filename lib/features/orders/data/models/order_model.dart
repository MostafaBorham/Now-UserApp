import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/tracking_order/data/models/delivery_man_model.dart';

/// A single store's order, with its own totals and [items]. Used both for the
/// draft group in checkout and for placed orders in the orders feature.
///
/// The two endpoints name the money fields differently — checkout's draft
/// returns `tax` / `discount` / `total`, `/api/v1/my/orders` returns
/// `tax_amount` / `discount_amount` / `total_amount` — so [fromJson] reads the
/// plain key first and falls back to the `*_amount` one.
///
/// Line items are parsed as [ProductModel] — the order-item payload is a strict
/// subset of the product payload, so we remap the `product_*` / `unit_price`
/// keys onto the product schema instead of maintaining a parallel model.
class OrderModel {
  final int? id;
  final String? uuid;
  final String? orderNumber;
  final int? orderGroupId;
  final int? vendorId;
  final int? branchId;

  /// The store this order is placed with. Populated from the nested `vendor`
  /// object on the response, mirroring the cart's convention — only the
  /// display-facing slice (`id`, `name`, `logo_url`) is carried so the card
  /// header can render without a second lookup.
  final StoreModel vendor;

  /// The customer who placed the order, as the lite slice the order payload
  /// carries (`id`, `name`, `phone`) — not the authenticated-user model.
  final OrderUserModel user;

  /// The courier assigned to this order, from the nested `driver` object.
  /// Null until a delivery man is assigned (i.e. before the order is out for
  /// delivery).
  final DeliveryManModel? driver;

  /// The raw machine status key (`pending`, `delivered`, …) used for logic.
  /// For the human-readable label use [orderStatus] instead.
  final String? status;

  /// The localized order status, read from `order_status`. The API sends it as
  /// a translation map (`{'ar': ..., 'en': ...}`); when only the machine
  /// [status] string is present (e.g. the checkout draft payload) it is
  /// normalized into a map with both languages set to it, so the presentation
  /// layer always reads it through [BuildContext.getLocalizedApiText].
  final Map<String, dynamic>? orderStatus;

  /// Whether this order currently exposes live driver tracking (`is_tracking`).
  final bool isTracking;

  final String? paymentStatus;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double discount;
  final double driverTip;
  final double total;
  final String? paymentMethod;
  final String? deliveryAddress;

  /// The delivery region split into `city` / `area`, from the `region` object.
  final OrderRegionModel region;

  final String? cancelReason;
  final String? notes;

  /// Lifecycle timestamps, kept as the raw ISO-8601 strings the API sends;
  /// parse/format them at the presentation layer.
  final String? estimatedDeliveryTime;
  final String? deliveredTime;
  final String? respondByAt;
  final String? acceptedAt;
  final String? preparedAt;
  final String? pickupArrivedAt;
  final String? pickedUpAt;
  final String? deliveryArrivedAt;
  final String? cancelledAt;
  final String? createdAt;
  final String? updatedAt;

  /// The delivered-at value. Like [status], the API may send it as a plain
  /// string or as a translation map (`{'ar': ..., 'en': ...}`); a plain string
  /// is normalized to a map with both languages set to it, so the presentation
  /// layer reads it through [BuildContext.getLocalizedApiText].
  final Map<String, dynamic>? deliveredAt;

  final List<ProductModel> items;

  const OrderModel({
    this.id,
    this.uuid,
    this.orderNumber,
    this.orderGroupId,
    this.vendorId,
    this.branchId,
    this.vendor = const StoreModel(),
    this.user = const OrderUserModel(),
    this.driver,
    this.status,
    this.orderStatus,
    this.isTracking = false,
    this.paymentStatus,
    this.subtotal = 0,
    this.tax = 0,
    this.deliveryFee = 0,
    this.discount = 0,
    this.driverTip = 0,
    this.total = 0,
    this.paymentMethod,
    this.deliveryAddress,
    this.region = const OrderRegionModel(),
    this.cancelReason,
    this.notes,
    this.estimatedDeliveryTime,
    this.deliveredTime,
    this.respondByAt,
    this.acceptedAt,
    this.preparedAt,
    this.pickupArrivedAt,
    this.pickedUpAt,
    this.deliveryArrivedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
    this.items = const <ProductModel>[],
  });

  factory OrderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OrderModel();
    }

    final Map<String, dynamic>? vendor =
        json['vendor'] as Map<String, dynamic>?;

    return OrderModel(
      id: (json['id'] as num?)?.toInt(),
      uuid: json['uuid']?.toString(),
      orderNumber: json['order_number']?.toString(),
      orderGroupId: (json['order_group_id'] as num?)?.toInt(),
      vendorId: (json['vendor_id'] as num?)?.toInt(),
      branchId: (json['branch_id'] as num?)?.toInt(),
      vendor: StoreModel.fromJson(<String, dynamic>{
        'id': vendor?['id'],
        'name': vendor?['name'],
        'logo_url': vendor?['logo_url'],
      }),
      user: OrderUserModel.fromJson(json['user'] as Map<String, dynamic>?),
      driver: json['driver'] is Map<String, dynamic>
          ? DeliveryManModel.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      status: json['status']?.toString(),
      orderStatus: (json['order_status'] is Map)
          ? json['order_status'] as Map<String, dynamic>
          : (json['status'] is String)
          ? {'ar': json['status'] as String, 'en': json['status'] as String}
          : null,
      isTracking: json['is_tracking'] as bool? ?? false,
      paymentStatus: json['payment_status']?.toString(),
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '') ?? 0.0,
      tax:
          double.tryParse(
            (json['tax'] ?? json['tax_amount'])?.toString() ?? '',
          ) ??
          0.0,
      deliveryFee:
          double.tryParse(json['delivery_fee']?.toString() ?? '') ?? 0.0,
      discount:
          double.tryParse(
            (json['discount'] ?? json['discount_amount'])?.toString() ?? '',
          ) ??
          0.0,
      driverTip: double.tryParse(json['driver_tip']?.toString() ?? '') ?? 0.0,
      total:
          double.tryParse(
            (json['total'] ?? json['total_amount'])?.toString() ?? '',
          ) ??
          0.0,
      paymentMethod: json['payment_method']?.toString(),
      deliveryAddress: json['delivery_address']?.toString(),
      region: OrderRegionModel.fromJson(json['region'] as Map<String, dynamic>?),
      cancelReason: json['cancel_reason']?.toString(),
      notes: json['notes']?.toString(),
      estimatedDeliveryTime: json['estimated_delivery_time']?.toString(),
      deliveredTime: json['delivered_time']?.toString(),
      respondByAt: json['respond_by_at']?.toString(),
      acceptedAt: json['accepted_at']?.toString(),
      preparedAt: json['prepared_at']?.toString(),
      pickupArrivedAt: json['pickup_arrived_at']?.toString(),
      pickedUpAt: json['picked_up_at']?.toString(),
      deliveryArrivedAt: json['delivery_arrived_at']?.toString(),
      deliveredAt: (json['delivered_at'] is String)
          ? {
              'ar': json['delivered_at'] as String,
              'en': json['delivered_at'] as String,
            }
          : json['delivered_at'],
      cancelledAt: json['cancelled_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      items:
          (json['items'] as List?)?.map((e) {
            final Map<String, dynamic> item =
                (e as Map<String, dynamic>?) ?? <String, dynamic>{};
            final Map<String, dynamic>? product =
                item['product'] as Map<String, dynamic>?;
            // Prefer the nested `product` object (localized name, images,
            // rating, deal) when present, overlaying the ordered [quantity]
            // from the line item. Fall back to remapping the flat order-item
            // keys onto the product schema for payloads (e.g. the checkout
            // draft) that don't nest a full product.
            if (product != null) {
              return ProductModel.fromJson(<String, dynamic>{
                ...product,
                'quantity': item['quantity'],
              });
            }
            return ProductModel.fromJson(<String, dynamic>{
              ...item,
              'product_id': item['product_id'],
              'name': item['product_name'],
              'sku': item['product_sku'],
              'price': item['unit_price'],
            });
          }).toList() ??
          const <ProductModel>[],
    );
  }
}

/// The delivery region carried on an order payload (`region` object), split
/// into its `city` and `area` parts.
class OrderRegionModel {
  final String? city;
  final String? area;

  const OrderRegionModel({this.city, this.area});

  factory OrderRegionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OrderRegionModel();
    }

    return OrderRegionModel(
      city: json['city']?.toString(),
      area: json['area']?.toString(),
    );
  }
}

/// The customer slice carried on an order payload (`user` object).
///
/// Deliberately separate from the auth feature's `UserModel`: that one models
/// the authenticated account (roles, permissions, profile completion), this one
/// only the three display fields an order carries.
class OrderUserModel {
  final int? id;
  final String? name;
  final String? phone;

  const OrderUserModel({this.id, this.name, this.phone});

  factory OrderUserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OrderUserModel();
    }

    return OrderUserModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}
