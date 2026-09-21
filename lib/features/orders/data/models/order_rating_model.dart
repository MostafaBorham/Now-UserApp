/// The `rating` object on an order payload: the gate on whether the order can
/// still be rated ([canRate]) plus, once rated, the submitted scores and
/// comments for each product, the store ([vendor]) and the courier
/// ([delivery]).
class OrderRatingModel {
  final bool canRate;
  final String? reasonCode;
  final bool isFullyRated;
  final List<RatedProductModel> products;
  final RatedSubjectModel vendor;
  final RatedSubjectModel delivery;

  const OrderRatingModel({
    this.canRate = true,
    this.reasonCode,
    this.isFullyRated = false,
    this.products = const <RatedProductModel>[],
    this.vendor = const RatedSubjectModel(),
    this.delivery = const RatedSubjectModel(),
  });

  factory OrderRatingModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OrderRatingModel();
    }

    return OrderRatingModel(
      canRate: json['can_rate'] as bool? ?? true,
      reasonCode: json['reason_code']?.toString(),
      isFullyRated: json['is_fully_rated'] as bool? ?? false,
      products:
          (json['products'] as List?)
              ?.map(
                (e) => RatedProductModel.fromJson(e as Map<String, dynamic>?),
              )
              .toList() ??
          const <RatedProductModel>[],
      vendor: RatedSubjectModel.fromJson(
        json['vendor'] as Map<String, dynamic>?,
      ),
      delivery: RatedSubjectModel.fromJson(
        json['delivery'] as Map<String, dynamic>?,
      ),
    );
  }
}

/// A single order line item's rating slot: the product's display fields plus
/// whether it [isRated] and, if so, the submitted [rating] detail.
class RatedProductModel {
  final int? productId;
  final int? orderItemId;
  final Map<String, dynamic>? name;
  final String? imageUrl;
  final bool isRated;
  final RatingDetailModel? rating;

  const RatedProductModel({
    this.productId,
    this.orderItemId,
    this.name,
    this.imageUrl,
    this.isRated = false,
    this.rating,
  });

  factory RatedProductModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const RatedProductModel();
    }

    return RatedProductModel(
      productId: (json['product_id'] as num?)?.toInt(),
      orderItemId: (json['order_item_id'] as num?)?.toInt(),
      name: json['name'] is Map ? json['name'] as Map<String, dynamic> : null,
      imageUrl: json['image_url']?.toString(),
      isRated: json['is_rated'] as bool? ?? false,
      rating: json['rating'] is Map
          ? RatingDetailModel.fromJson(json['rating'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// A non-product rating slot — the store (`vendor`) or the courier
/// (`delivery`). Both carry an id, a display name and image, whether they were
/// rated and the submitted [rating]; the `name` arrives as a translation map for
/// the vendor and a plain string for the delivery agent, so a bare string is
/// normalized into a map with both languages set to it.
class RatedSubjectModel {
  final int? id;
  final Map<String, dynamic>? name;
  final String? imageUrl;
  final bool isRated;
  final RatingDetailModel? rating;

  const RatedSubjectModel({
    this.id,
    this.name,
    this.imageUrl,
    this.isRated = false,
    this.rating,
  });

  factory RatedSubjectModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const RatedSubjectModel();
    }

    final dynamic rawName = json['name'];

    return RatedSubjectModel(
      id: ((json['vendor_id'] ?? json['delivery_id']) as num?)?.toInt(),
      name: rawName is Map
          ? rawName as Map<String, dynamic>
          : rawName is String
          ? {'ar': rawName, 'en': rawName}
          : null,
      imageUrl: (json['logo_url'] ?? json['image_url'])?.toString(),
      isRated: json['is_rated'] as bool? ?? false,
      rating: json['rating'] is Map
          ? RatingDetailModel.fromJson(json['rating'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// The submitted rating itself: the star [rate], the numeric [score], the
/// optional [comment] and its moderation [status], when it was [ratedAt] and
/// whether the shopper may still edit it ([canEdit]).
class RatingDetailModel {
  final int? id;
  final int? rate;
  final int? score;
  final String? comment;
  final String? status;
  final String? ratedAt;
  final bool canEdit;

  const RatingDetailModel({
    this.id,
    this.rate,
    this.score,
    this.comment,
    this.status,
    this.ratedAt,
    this.canEdit = false,
  });

  factory RatingDetailModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const RatingDetailModel();
    }

    return RatingDetailModel(
      id: (json['id'] as num?)?.toInt(),
      rate: (json['rate'] as num?)?.toInt(),
      score: (json['score'] as num?)?.toInt(),
      comment: json['comment']?.toString(),
      status: json['status']?.toString(),
      ratedAt: json['rated_at']?.toString(),
      canEdit: json['can_edit'] as bool? ?? false,
    );
  }
}
