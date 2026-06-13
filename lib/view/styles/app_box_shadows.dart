import 'package:flutter/material.dart';

class AppBoxShadows {
  AppBoxShadows._();

  static final List<BoxShadow> blackBottomShadow1 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.6),
      blurRadius: 1,
      spreadRadius: 0,
      offset: const Offset(0, 1),
    ),
  ];
}