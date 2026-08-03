import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';

/// A single store's order, with its own totals and [items]. Used both for the
/// draft group in checkout and — going forward — for placed orders in the
/// orders feature.
class OrderModel {
  final String? uuid;
  final String? orderNumber;
  final int? vendorId;
  final int? branchId;

  /// The store this order is placed with. Populated from the nested `vendor`
  /// object on the response, mirroring the cart's convention — only the
  /// display-facing slice (`id`, `name`, `logo_url`) is carried so the card
  /// header can render without a second lookup.
  final StoreModel vendor;

  final String? status;
  final String? paymentStatus;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double discount;
  final double total;
  final List<OrderItemModel> items;

  const OrderModel({
    this.uuid,
    this.orderNumber,
    this.vendorId,
    this.branchId,
    this.vendor = const StoreModel(),
    this.status,
    this.paymentStatus,
    this.subtotal = 0,
    this.tax = 0,
    this.deliveryFee = 0,
    this.discount = 0,
    this.total = 0,
    this.items = const <OrderItemModel>[],
  });

  factory OrderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OrderModel();
    }

    final Map<String, dynamic>? vendor =
        json['vendor'] as Map<String, dynamic>?;

    return OrderModel(
      uuid: json['uuid']?.toString(),
      orderNumber: json['order_number']?.toString(),
      vendorId: (json['vendor_id'] as num?)?.toInt(),
      branchId: (json['branch_id'] as num?)?.toInt(),
      // Same lite slice the cart pulls from its own `vendor` object.
      vendor: StoreModel.fromJson(<String, dynamic>{
        'id': vendor?['id'],
        'name': vendor?['name'],
        'logo_url': vendor?['logo_url'],
      }),
      status: json['status']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '') ?? 0.0,
      tax: double.tryParse(json['tax']?.toString() ?? '') ?? 0.0,
      deliveryFee:
          double.tryParse(json['delivery_fee']?.toString() ?? '') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '') ?? 0.0,
      items:
          (json['items'] as List?)
              ?.map(
                (e) => OrderItemModel.fromJson(e as Map<String, dynamic>?),
              )
              .toList() ??
          const <OrderItemModel>[],
    );
  }
}

/// A single line item inside an [OrderModel].
class OrderItemModel {
  final int? productId;

  /// Localized product name as an API translation map (`{'en': ..., 'ar': ...}`).
  /// Resolve it for display with `context.getLocalizedApiText(productName)`.
  final Map<String, dynamic>? productName;
  final String? productSku;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItemModel({
    this.productId,
    this.productName,
    this.productSku,
    this.quantity = 0,
    this.unitPrice = 0,
    this.totalPrice = 0,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OrderItemModel();
    }

    return OrderItemModel(
      productId: (json['product_id'] as num?)?.toInt(),
      productName: json['product_name'] as Map<String, dynamic>?,
      productSku: json['product_sku']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '') ?? 0.0,
    );
  }
}
