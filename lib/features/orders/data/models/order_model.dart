import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';

/// A single store's order, with its own totals and [items]. Used both for the
/// draft group in checkout and — going forward — for placed orders in the
/// orders feature.
///
/// Line items are parsed as [ProductModel] — the order-item payload is a strict
/// subset of the product payload, so we remap the `product_*` / `unit_price`
/// keys onto the product schema instead of maintaining a parallel model.
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
  final List<ProductModel> items;

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
    this.items = const <ProductModel>[],
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
