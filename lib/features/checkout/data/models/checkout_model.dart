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

/// The draft order group: totals for the whole checkout plus its per-store
/// [orders]. Nullable fields (`payment_method`, `address_id`, …) stay `null`
/// until the user fills them in later in the checkout flow.
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
  final List<DraftOrderModel> orders;

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
    this.orders = const <DraftOrderModel>[],
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
      orders: (json['orders'] as List?)
              ?.map((e) => DraftOrderModel.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          const <DraftOrderModel>[],
    );
  }
}

/// A single store's order within the draft group, with its own totals and
/// [items].
class DraftOrderModel {
  final String? uuid;
  final String? orderNumber;
  final int? vendorId;
  final int? branchId;
  final String? status;
  final String? paymentStatus;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double discount;
  final double total;
  final List<DraftOrderItemModel> items;

  const DraftOrderModel({
    this.uuid,
    this.orderNumber,
    this.vendorId,
    this.branchId,
    this.status,
    this.paymentStatus,
    this.subtotal = 0,
    this.tax = 0,
    this.deliveryFee = 0,
    this.discount = 0,
    this.total = 0,
    this.items = const <DraftOrderItemModel>[],
  });

  factory DraftOrderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DraftOrderModel();
    }

    return DraftOrderModel(
      uuid: json['uuid']?.toString(),
      orderNumber: json['order_number']?.toString(),
      vendorId: (json['vendor_id'] as num?)?.toInt(),
      branchId: (json['branch_id'] as num?)?.toInt(),
      status: json['status']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '') ?? 0.0,
      tax: double.tryParse(json['tax']?.toString() ?? '') ?? 0.0,
      deliveryFee:
          double.tryParse(json['delivery_fee']?.toString() ?? '') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '') ?? 0.0,
      items: (json['items'] as List?)
              ?.map(
                (e) => DraftOrderItemModel.fromJson(e as Map<String, dynamic>?),
              )
              .toList() ??
          const <DraftOrderItemModel>[],
    );
  }
}

/// A single line item inside a [DraftOrderModel].
class DraftOrderItemModel {
  final int? productId;
  final String? productName;
  final String? productSku;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const DraftOrderItemModel({
    this.productId,
    this.productName,
    this.productSku,
    this.quantity = 0,
    this.unitPrice = 0,
    this.totalPrice = 0,
  });

  factory DraftOrderItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DraftOrderItemModel();
    }

    return DraftOrderItemModel(
      productId: (json['product_id'] as num?)?.toInt(),
      productName: json['product_name']?.toString(),
      productSku: json['product_sku']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '') ?? 0.0,
    );
  }
}
