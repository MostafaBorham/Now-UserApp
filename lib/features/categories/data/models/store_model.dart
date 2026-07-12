class StoreModel {
  final int? id;
  final String? name;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;
  final bool? isOpen;
  final bool? acceptingOrders;
  final double? minOrderValue;
  final double? rating;
  final int? ratingCount;
  final double? deliveryFee;
  final int? deliveryTime;
  final double? distance;

  const StoreModel({
    this.id,
    this.name,
    this.description,
    this.logoUrl,
    this.coverUrl,
    this.isOpen,
    this.acceptingOrders,
    this.minOrderValue,
    this.rating,
    this.ratingCount,
    this.deliveryFee,
    this.deliveryTime,
    this.distance,
  });

  factory StoreModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const StoreModel();
    }

    return StoreModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      coverUrl: json['cover_url']?.toString(),
      isOpen: json['is_open'] as bool?,
      acceptingOrders: json['accepting_orders'] as bool?,
      minOrderValue: (json['min_order_value'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: (json['rating_count'] as num?)?.toInt(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
      deliveryTime: (json['delivery_time'] as num?)?.toInt(),
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'cover_url': coverUrl,
      'is_open': isOpen,
      'accepting_orders': acceptingOrders,
      'min_order_value': minOrderValue,
      'rating': rating,
      'rating_count': ratingCount,
      'delivery_fee': deliveryFee,
      'delivery_time': deliveryTime,
      'distance': distance,
    };
  }

  StoreModel copyWith({
    int? id,
    String? name,
    String? description,
    String? logoUrl,
    String? coverUrl,
    bool? isOpen,
    bool? acceptingOrders,
    double? minOrderValue,
    double? rating,
    int? ratingCount,
    double? deliveryFee,
    int? deliveryTime,
    double? distance,
  }) {
    return StoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      isOpen: isOpen ?? this.isOpen,
      acceptingOrders: acceptingOrders ?? this.acceptingOrders,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      distance: distance ?? this.distance,
    );
  }
}
