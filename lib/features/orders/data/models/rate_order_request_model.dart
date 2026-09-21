import 'package:equatable/equatable.dart';

class RateOrderRequest extends Equatable {
  final int orderId;
  final List<RateProductEntry> products;
  final RateSubjectEntry? vendor;
  final RateSubjectEntry? delivery;

  const RateOrderRequest({
    required this.orderId,
    this.products = const <RateProductEntry>[],
    this.vendor,
    this.delivery,
  });

  factory RateOrderRequest.build({
    required int orderId,
    required List<int?> productIds,
    required List<int> productRatings,
    required List<String> productComments,
    int? vendorId,
    int vendorRating = 0,
    String vendorComment = '',
    int? deliveryId,
    int deliveryRating = 0,
    String deliveryComment = '',
  }) {
    final List<RateProductEntry> products = <RateProductEntry>[];
    for (int i = 0; i < productIds.length; i++) {
      final int? productId = productIds[i];
      final int rate = i < productRatings.length ? productRatings[i] : 0;
      if (productId == null || rate < 1) continue;
      products.add(
        RateProductEntry(
          productId: productId,
          rate: rate,
          comment: _clean(i < productComments.length ? productComments[i] : ''),
        ),
      );
    }

    return RateOrderRequest(
      orderId: orderId,
      products: products,
      vendor: (vendorId != null && vendorRating >= 1)
          ? RateSubjectEntry(
              idKey: 'vendor_id',
              id: vendorId,
              rate: vendorRating,
              comment: _clean(vendorComment),
            )
          : null,
      delivery: (deliveryId != null && deliveryRating >= 1)
          ? RateSubjectEntry(
              idKey: 'delivery_id',
              id: deliveryId,
              rate: deliveryRating,
              comment: _clean(deliveryComment),
            )
          : null,
    );
  }

  static String? _clean(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'order_id': orderId,
      'products': products.map((RateProductEntry e) => e.toJson()).toList(),
      if (vendor != null) 'vendor': vendor!.toJson(),
      if (delivery != null) 'delivery': delivery!.toJson(),
    };
  }

  @override
  List<Object?> get props => <Object?>[orderId, products, vendor, delivery];
}

class RateProductEntry extends Equatable {
  final int productId;
  final int rate;
  final String? comment;

  const RateProductEntry({
    required this.productId,
    required this.rate,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'product_id': productId,
      'rate': rate,
      'comment': comment,
    };
  }

  @override
  List<Object?> get props => <Object?>[productId, rate, comment];
}

class RateSubjectEntry extends Equatable {
  final String idKey;
  final int id;
  final int rate;
  final String? comment;

  const RateSubjectEntry({
    required this.idKey,
    required this.id,
    required this.rate,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      idKey: id,
      'rate': rate,
      'comment': comment,
    };
  }

  @override
  List<Object?> get props => <Object?>[idKey, id, rate, comment];
}
