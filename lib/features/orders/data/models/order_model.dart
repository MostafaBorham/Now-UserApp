import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';

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

  final String? status;
  final String? paymentStatus;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double discount;
  final double driverTip;
  final double total;
  final String? paymentMethod;
  final String? deliveryAddress;
  final String? cancelReason;
  final String? notes;

  /// Lifecycle timestamps, kept as the raw ISO-8601 strings the API sends;
  /// parse/format them at the presentation layer.
  final String? estimatedDeliveryTime;
  final String? respondByAt;
  final String? acceptedAt;
  final String? preparedAt;
  final String? pickedUpAt;
  final String? deliveredAt;
  final String? cancelledAt;
  final String? createdAt;
  final String? updatedAt;

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
    this.status,
    this.paymentStatus,
    this.subtotal = 0,
    this.tax = 0,
    this.deliveryFee = 0,
    this.discount = 0,
    this.driverTip = 0,
    this.total = 0,
    this.paymentMethod,
    this.deliveryAddress,
    this.cancelReason,
    this.notes,
    this.estimatedDeliveryTime,
    this.respondByAt,
    this.acceptedAt,
    this.preparedAt,
    this.pickedUpAt,
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
      status: json['status']?.toString(),
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
      cancelReason: json['cancel_reason']?.toString(),
      notes: json['notes']?.toString(),
      estimatedDeliveryTime: json['estimated_delivery_time']?.toString(),
      respondByAt: json['respond_by_at']?.toString(),
      acceptedAt: json['accepted_at']?.toString(),
      preparedAt: json['prepared_at']?.toString(),
      pickedUpAt: json['picked_up_at']?.toString(),
      deliveredAt: json['delivered_at']?.toString(),
      cancelledAt: json['cancelled_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      items:
          (json['items'] as List?)?.map((e) {
            final Map<String, dynamic> item =
                (e as Map<String, dynamic>?) ?? <String, dynamic>{};
            // Remap the order-item keys onto the product schema so
            // ProductModel.fromJson can consume them directly.
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
