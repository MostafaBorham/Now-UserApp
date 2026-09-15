import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryStoresSearchProvider =
    StateProvider.autoDispose<String>((Ref ref) => '');
