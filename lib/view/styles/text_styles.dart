

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyles{
  static TextStyle get style20SemiBold=> TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    overflow: TextOverflow.ellipsis,
  );
  static TextStyle get style12Regular=> TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    overflow: TextOverflow.ellipsis,
  );
  static TextStyle get style16Regular=> TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    overflow: TextOverflow.ellipsis,
  );
}