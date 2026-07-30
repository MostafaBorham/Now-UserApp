import 'package:flutter_riverpod/flutter_riverpod.dart';

final productQuantityProvider =
StateProvider.autoDispose.family<int, int>((ref, initialValue) {
  return initialValue;
});