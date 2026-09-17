import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';

final productProvider =
Provider.autoDispose<ProductModel>((ref) {
  throw UnimplementedError();
});