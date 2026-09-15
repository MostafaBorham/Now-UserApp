import 'package:equatable/equatable.dart';




class FavouriteModel extends Equatable {
  final int? id;
  final String? type;
  final int? favoritableId;
  final FavoritableModel? favoritable;
  final String? createdAt;

  const FavouriteModel({
    this.id,
    this.type,
    this.favoritableId,
    this.favoritable,
    this.createdAt,
  });

  factory FavouriteModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const FavouriteModel();
    }

    return FavouriteModel(
      id: (json['id'] as num?)?.toInt(),
      type: json['type']?.toString(),
      favoritableId: (json['favoritable_id'] as num?)?.toInt(),
      favoritable: FavoritableModel.fromJson(
        json['favoritable'] as Map<String, dynamic>?,
      ),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'favoritable_id': favoritableId,
      'favoritable': favoritable?.toJson(),
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        favoritableId,
        favoritable,
        createdAt,
      ];
}


class FavoritableModel extends Equatable {
  final int? id;



  final Map<String, dynamic>? name;
  final String? slug;
  final String? price;

  const FavoritableModel({
    this.id,
    this.name,
    this.slug,
    this.price,
  });

  factory FavoritableModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const FavoritableModel();
    }

    return FavoritableModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as Map<String, dynamic>?,
      slug: json['slug']?.toString(),
      price: json['price']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [id, name, slug, price];
}
