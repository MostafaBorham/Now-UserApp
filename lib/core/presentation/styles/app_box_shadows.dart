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

  static final List<BoxShadow> blackBottomShadow2 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 10,
      spreadRadius: 0,
      offset: const Offset(0, 1),
    ),
  ];

  static final List<BoxShadow> blackElevation1 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 1,
      spreadRadius: 0.5,
      offset: const Offset(0, 0),
    ),
  ];

  static final List<BoxShadow> greyElevation2 = [BoxShadow(
    color: const Color(0x14000000), // #00000014
    offset: const Offset(0, 4),
    blurRadius: 16,
    spreadRadius: 0,
  )];

  static final List<BoxShadow> greyElevation3 = [BoxShadow(
    color: const Color(0x0F000000), // #0000000F (black 6%)
    offset: const Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 0,
  )];

  static final List<BoxShadow> brandCard = [
    BoxShadow(
      color: const Color(0x0F000000), // black 6%
      offset: const Offset(0, 12),
      blurRadius: 28,
      spreadRadius: -12,
    ),
    BoxShadow(
      color: const Color(0x0A000000), // black 4%
      offset: const Offset(0, 2),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];
}