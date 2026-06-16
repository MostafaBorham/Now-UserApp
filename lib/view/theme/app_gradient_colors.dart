import 'package:flutter/material.dart';

abstract class AppGradientColors {
  static final gradient1 = LinearGradient(
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
    colors: [Color(0xffFFFDE6), Color(0xffDBF1DB)],
    stops: [0,1]
  );
}
