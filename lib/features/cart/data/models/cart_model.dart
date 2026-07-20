import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';

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
      minOrderValue: json['min_order_value'] ?? 0,
      minOrderMet: json['min_order_met'] as bool? ?? false,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '') ?? 0.0,
      tax: double.tryParse(json['tax']?.toString() ?? '') ?? 0.0,
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? '') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '') ?? 0.0,
    );
  }
}