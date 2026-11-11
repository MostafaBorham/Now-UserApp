import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

/// Supplies the products belonging to the list a card was tapped in.
///
/// Read at tap time so paginated lists include every loaded page without
/// rebuilding their existing cards when another page arrives.
class ProductDetailsListScope extends InheritedWidget {
  const ProductDetailsListScope({
    super.key,
    required this.productSlugs,
    required super.child,
  });

  final Iterable<String?> Function() productSlugs;

  static void open(
    BuildContext context,
    String? productSlug, {
    Iterable<String?>? productSlugs,
  }) {
    if (productSlug == null || productSlug.trim().isEmpty) return;
    final scope = context
        .getInheritedWidgetOfExactType<ProductDetailsListScope>();
    final slugs = <String>{
      ...?(productSlugs ?? scope?.productSlugs())?.whereType<String>().where(
        (slug) => slug.trim().isNotEmpty,
      ),
    }.toList();
    if (!slugs.contains(productSlug)) slugs.add(productSlug);

    context.pushNamed(
      AppRoutes.productDetailsScreen,
      extra: slugs.length == 1
          ? productSlug
          : <String, Object>{
              'productSlugs': slugs,
              'initialIndex': slugs.indexOf(productSlug),
            },
    );
  }

  @override
  bool updateShouldNotify(ProductDetailsListScope oldWidget) => false;
}
