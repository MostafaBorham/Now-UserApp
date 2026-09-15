import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryProductsSearchProvider =
    StateProvider.autoDispose<String>((Ref ref) => '');
