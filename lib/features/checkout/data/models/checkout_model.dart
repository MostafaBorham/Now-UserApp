import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';

/// Parsed representation of a checkout draft (`/api/v1/checkout/draft`).
///
/// Shared by both flows — all-stores and single-store — since the endpoint
/// returns the same shape for each. [fromJson] receives the response `data`
/// object and reads the nested `order_group` internally, mirroring the cart
/// model convention.
class CheckoutModel {
  final OrderGroupModel orderGroup;

  const CheckoutModel({this.orderGroup = const OrderGroupModel()});

  factory CheckoutModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CheckoutModel();
    }

    return CheckoutModel(
      orderGroup: OrderGroupModel.fromJson(
        json['order_group'] as Map<String, dynamic>?,
      ),
    );
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
