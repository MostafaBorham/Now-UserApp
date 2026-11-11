import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_body.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.productSlug});
  final String productSlug;

  @override
  Widget build(BuildContext context) =>
      ProductDetailsBody(productSlug: productSlug);
}
