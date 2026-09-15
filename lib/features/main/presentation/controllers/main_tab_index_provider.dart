import 'package:flutter_riverpod/flutter_riverpod.dart';

final AutoDisposeStateProvider<int> mainTabIndexProvider = StateProvider.autoDispose<int>((ref) => 0);
