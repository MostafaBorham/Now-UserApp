import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final int? discountPercentage;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.discountPercentage,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, discountPercentage];
}
