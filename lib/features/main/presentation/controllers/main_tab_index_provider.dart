import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The currently selected bottom-nav tab in [MainScreen].
///
/// Kept outside the widget's state so callers elsewhere (e.g. the empty cart's
/// "Browse products" button) can jump to a specific tab without threading a
/// controller through the widget tree.
final AutoDisposeStateProvider<int> mainTabIndexProvider = StateProvider.autoDispose<int>((ref) => 0);
