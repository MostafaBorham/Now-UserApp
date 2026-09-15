import 'package:equatable/equatable.dart';



class FavouriteCategoryModel extends Equatable {
  final int id;



  final Map<String, dynamic>? name;


  final int favoritablesCount;

  const FavouriteCategoryModel({
    required this.id,
    this.name,
    this.favoritablesCount = 0,
  });

  factory FavouriteCategoryModel.fromJson(Map<String, dynamic> json) {
    return FavouriteCategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as Map<String, dynamic>?,
      favoritablesCount: (json['favoritables_count'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, favoritablesCount];
}
