import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/enums/order_status.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_rating_model.dart';
import 'package:nowdelivery_user_app/features/tracking_order/data/models/delivery_man_model.dart';

/// A single store's order, with its own totals and [items]. Used both for a
/// store's group in the checkout preview and for placed orders in the orders
/// feature.
///
/// The two name the money fields differently — the checkout preview (as
/// `CheckoutModel` reshapes it) has `tax` / `discount` / `total`,
/// `/api/v1/my/orders` has `tax_amount` / `discount_amount` / `total_amount` —
/// so [fromJson] reads the plain key first and falls back to the `*_amount` one.
///
/// Line items are parsed as [ProductModel] (see [_line]) rather than a parallel
/// model, with the line's quantity and paid `unit_price` laid over the product;
/// lines the vendor refused are split out into [unavailableItems].
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
  /// [status] string is present it is normalized into a map with both
  /// languages set to it, so the presentation layer always reads it through
  /// [BuildContext.getLocalizedApiText].
  final Map<String, dynamic>? orderStatus;

  /// Whether this order currently exposes live driver tracking (`is_tracking`).
  final bool isTracking;

  /// The order's rating payload (`rating`): whether it can still be rated
  /// (`can_rate`) and, once rated, the per-product, vendor and delivery scores
  /// and comments. Drives the order-details screen's swap between the rate-order
  /// button and the read-only [OrderRatingView].
  final OrderRatingModel rating;

  final String? paymentStatus;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double discount;
  final double driverTip;
  final double total;

  /// The purchase voucher this order used (`voucher.code`) and its share of the
  /// order's discount (`voucher.discount_applied`). That share is already inside
  /// [discount]; see [couponDiscount].
  final String? voucherCode;
  final double voucherDiscount;

  final String? paymentMethod;
  final String? deliveryAddress;

  /// The delivery region split into `city` / `area`, from the `region` object.
  final OrderRegionModel region;

  final String? cancelReason;
  final String? notes;

  /// Absolute URL of the server-rendered invoice PDF (`invoice_pdf_url`), used
  /// by the order-details "print invoice" action to download the file. It is an
  /// authenticated `/api/v1/my/orders/...` link, so it must be fetched through
  /// the shared Dio (which attaches the session token), not opened externally.
  final String? invoicePdfUrl;

  /// Lifecycle timestamps, kept as the raw ISO-8601 strings the API sends;
  /// parse/format them at the presentation layer.
  final String? estimatedDeliveryTime;
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

  /// The lines that were sold. Each carries the line's `unit_price` — what was
  /// paid — as its [ProductModel.price], not the product's price today.
  final List<ProductModel> items;

  /// Lines the vendor accepted the order without (`is_unavailable`): kept on
  /// the order for history, excluded from every total, never delivered.
  final List<ProductModel> unavailableItems;

  /// The lifecycle state behind [status], for logic — `closed` resolved by
  /// whether the order was ever delivered (see [OrderStatus.fromKey]).
  OrderStatus get lifecycleStatus =>
      OrderStatus.fromKey(status, wasDelivered: deliveredAt != null);

  /// Support remains available for every order except closed and cancelled
  /// orders. Rejected orders share the cancelled lifecycle state.
  bool get canContactSupport =>
      status?.trim().toLowerCase() != 'closed' &&
      lifecycleStatus is! CancelledStatus;

  /// How many units were sold, across [items].
  int get itemsQuantity =>
      items.fold(0, (int sum, ProductModel item) => sum + (item.quantity ?? 0));

  /// [discount] without the voucher's share, which gets its own row.
  double get couponDiscount =>
      (sarDoubleToHalalas(discount) - sarDoubleToHalalas(voucherDiscount)) /
      halalasPerSar;

  /// What this order costs the customer: [total] plus the [driverTip] it
  /// carries. The backend keeps the tip outside `total_amount`, but orders from
  /// the older cart checkout added it inside; like the backend
  /// (`Order::tipInsideTotalHalalas`), a total that already covers the store's
  /// invoice plus the tip is taken to hold it.
  double get totalWithTip {
    final int tip = sarDoubleToHalalas(driverTip);
    final int storeTotal =
        sarDoubleToHalalas(subtotal) -
        sarDoubleToHalalas(discount) +
        sarDoubleToHalalas(tax) +
        sarDoubleToHalalas(deliveryFee);
    final int charged = sarDoubleToHalalas(total);
    final bool tipInside = tip <= 0 || charged >= storeTotal + tip;
    return (tipInside ? charged : charged + tip) / halalasPerSar;
  }

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
    this.rating = const OrderRatingModel(),
    this.paymentStatus,
    this.subtotal = 0,
    this.tax = 0,
    this.deliveryFee = 0,
    this.discount = 0,
    this.driverTip = 0,
    this.total = 0,
    this.voucherCode,
    this.voucherDiscount = 0,
    this.paymentMethod,
    this.deliveryAddress,
    this.region = const OrderRegionModel(),
    this.cancelReason,
    this.notes,
    this.invoicePdfUrl,
    this.estimatedDeliveryTime,
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
    this.unavailableItems = const <ProductModel>[],
  });

  factory OrderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OrderModel();
    }

    final Map<String, dynamic>? vendor =
        json['vendor'] as Map<String, dynamic>?;
    final List<Map<String, dynamic>> lines =
        ((json['items'] as List?) ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .toList();
    bool isUnavailable(Map<String, dynamic> line) =>
        line['is_unavailable'] == true;
    final Map<String, dynamic>? voucher =
        json['voucher'] is Map<String, dynamic>
        ? json['voucher'] as Map<String, dynamic>
        : null;

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
      rating: OrderRatingModel.fromJson(
        json['rating'] as Map<String, dynamic>?,
      ),
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
      voucherCode: voucher?['code']?.toString(),
      voucherDiscount:
          double.tryParse(voucher?['discount_applied']?.toString() ?? '') ??
          0.0,
      paymentMethod: json['payment_method']?.toString(),
      deliveryAddress: json['delivery_address']?.toString(),
      region: OrderRegionModel.fromJson(
        json['region'] as Map<String, dynamic>?,
      ),
      cancelReason: json['cancel_reason']?.toString(),
      notes: json['notes']?.toString(),
      invoicePdfUrl: json['invoice_pdf_url']?.toString(),
      estimatedDeliveryTime: json['estimated_delivery_time']?.toString(),
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
      items: lines
          .where((Map<String, dynamic> line) => !isUnavailable(line))
          .map(_line)
          .toList(),
      unavailableItems: lines.where(isUnavailable).map(_line).toList(),
    );
  }

  /// One order line as a [ProductModel]. The nested `product` (localized
  /// name, images) when there is one, else the flat line keys remapped onto
  /// the product schema (the checkout preview, a deleted product) — and either
  /// way the line's own quantity and `unit_price`. The nested product's
  /// `price` is what it costs *today*; after a price change it no longer adds
  /// up to the order's subtotal.
  static ProductModel _line(Map<String, dynamic> item) {
    final Map<String, dynamic>? product =
        item['product'] as Map<String, dynamic>?;

    return ProductModel.fromJson(<String, dynamic>{
      if (product != null)
        ...product
      else ...<String, dynamic>{
        ...item,
        'name': item['product_name'],
        'sku': item['product_sku'],
      },
      'quantity': item['quantity'],
      'price': item['unit_price'] ?? product?['price'],
    });
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
