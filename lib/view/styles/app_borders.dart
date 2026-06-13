import 'package:flutter/material.dart';

class AppBorders {
  AppBorders._();

  static Border b1(Color? color) => Border.all(
    width: 1,
    color: color ?? Colors.transparent
  );

  static Border b2(Color? color) => Border.all(
      width: 2,
      color: color ?? Colors.transparent
  );

  static Border b3(Color? color) => Border.all(
      width: 3,
      color: color ?? Colors.transparent
  );

  static Border b4(Color? color) => Border.all(
      width: 4,
      color: color ?? Colors.transparent
  );

  static Border b5(Color? color) => Border.all(
      width: 5,
      color: color ?? Colors.transparent
  );

  static Border b6(Color? color) => Border.all(
      width: 6,
      color: color ?? Colors.transparent
  );
}