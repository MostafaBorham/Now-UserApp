import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';

class CartModel {
  final int? id;
  final List<CartVendorModel> vendors;

  const CartModel({this.id, this.vendors = const <CartVendorModel>[]});

  factory CartModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CartModel();
    }

    final Map<String, dynamic>? cart = json['cart'] as Map<String, dynamic>?;

    return CartModel(
      id: (cart?['id'] as num?)?.toInt(),
      vendors:
          (cart?['vendors'] as List?)
              ?.map((e) => CartVendorModel.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          const <CartVendorModel>[],
    );
  }

  CartModel copyWith({int? id, List<CartVendorModel>? vendors}) {
    return CartModel(id: id ?? this.id, vendors: vendors ?? this.vendors);
  }

  /// This product's lines: one per variant (set of options) it is in the cart
  /// with. Cart lines carry the product id in `product_id`, while listing
  /// products carry it in `id` — match either.
  List<ProductModel> linesOf(int productId) => <ProductModel>[
    for (final CartVendorModel vendor in vendors)
      for (final ProductModel product in vendor.products)
        if ((product.productId ?? product.id) == productId) product,
  ];

  /// This product's first line, or `null` when the cart has none.
  ProductModel? lineOf(int productId) => linesOf(productId).firstOrNull;

  /// Units of this product in the cart, across all its variant lines; `0` when
  /// it is not in it at all. Summed: the first line alone showed one variant's
  /// count on the product cards (BUG-022, QA V2).
  int quantityOf(int productId) => linesOf(
    productId,
  ).fold<int>(0, (int sum, ProductModel line) => sum + (line.quantity ?? 0));

  /// Total units across every store line — the number shown on the cart badge.
  int get itemCount => vendors.fold<int>(
        0,
        (int sum, CartVendorModel vendor) =>
            sum +
            vendor.products
                .fold<int>(0, (int s, ProductModel p) => s + (p.quantity ?? 0)),
      );
}

class CartVendorModel {
  final StoreModel vendor;
  final List<ProductModel> products;
  final CartVendorPricingModel pricing;

  const CartVendorModel({
    this.vendor = const StoreModel(),
    this.products = const <ProductModel>[],
    this.pricing = const CartVendorPricingModel(),
  });

  factory CartVendorModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CartVendorModel();
    }

    final Map<String, dynamic>? vendor =
        json['vendor'] as Map<String, dynamic>?;

    return CartVendorModel(
      vendor: StoreModel.fromJson(<String, dynamic>{
        'id': vendor?['id'],
        'name': vendor?['name'],
        'logo_url': vendor?['logo_url'],
      }),
      products:
          (json['products'] as List?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ProductModel>[],
      pricing: CartVendorPricingModel.fromJson(
        json['pricing'] as Map<String, dynamic>?,
      ),
    );
  }

  /// The quantity each line must drop to for this store to fit the stock it
  /// has; lines that already fit are left out, and `0` means remove the line.
  ///
  /// The server never trims a line itself, so a cart can hold more than is
  /// left once stock moves after the add (other orders, a vendor edit, a guest
  /// cart merged at login). Stock is held per product: every variant line of a
  /// product carries the same `stock`, and the server refuses a quantity that
  /// takes the product's total past it or under the product's minimum. So the
  /// lines keep their quantity while the stock lasts, the line it runs out on
  /// gets what is left, the rest go to 0 — and all of them do when what is
  /// left is under the minimum. A `null` stock (product gone) is not judged.
  Map<ProductModel, int> get stockFixes {
    final Map<int, List<ProductModel>> linesByProduct =
        <int, List<ProductModel>>{};
    for (final ProductModel line in products) {
      final int? productId = line.productId ?? line.id;
      if (productId == null || line.stock == null) continue;
      (linesByProduct[productId] ??= <ProductModel>[]).add(line);
    }

    final Map<ProductModel, int> fixes = <ProductModel, int>{};
    for (final List<ProductModel> lines in linesByProduct.values) {
      final int stock = lines.first.stock!;
      final int total = lines.fold<int>(
        0,
        (int sum, ProductModel line) => sum + (line.quantity ?? 0),
      );
      if (total <= stock) continue;

      int left = stock < (lines.first.minOrderQuantity ?? 1) ? 0 : stock;
      for (final ProductModel line in lines) {
        final int quantity = line.quantity ?? 0;
        final int fitted = quantity < left ? quantity : left;
        left -= fitted;
        if (fitted != quantity) fixes[line] = fitted;
      }
    }
    return fixes;
  }
}

class CartVendorPricingModel {
  final bool available;
  final double minOrderValue;
  final bool minOrderMet;
  final double subtotal;
  final double discount;
  final double tax;
  final double deliveryFee;
  final double total;

  const CartVendorPricingModel({
    this.available = false,
    this.minOrderValue = 0,
    this.minOrderMet = false,
    this.subtotal = 0,
    this.discount = 0,
    this.tax = 0,
    this.deliveryFee = 0,
    this.total = 0,
  });

  factory CartVendorPricingModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CartVendorPricingModel();
    }

    return CartVendorPricingModel(
      available: json['available'] as bool? ?? false,
      // `as num?` first: the server sends this one as a plain `100` often
      // enough, and a bare `json[...] ?? 0` into a `double` throws on it.
      minOrderValue: (json['min_order_value'] as num?)?.toDouble() ?? 0,
      minOrderMet: json['min_order_met'] as bool? ?? false,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '') ?? 0.0,
      tax: double.tryParse(json['tax']?.toString() ?? '') ?? 0.0,
      deliveryFee:
          double.tryParse(json['delivery_fee']?.toString() ?? '') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '') ?? 0.0,
    );
  }
}
