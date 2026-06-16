import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeController {
  final sliderIndexProvider  = StateProvider.autoDispose<int>(
        (ref) => 0,
  );
}