import 'package:flutter_riverpod/flutter_riverpod.dart';

final productQuantityProvider =
StateProvider.autoDispose<int>((ref) => 1);