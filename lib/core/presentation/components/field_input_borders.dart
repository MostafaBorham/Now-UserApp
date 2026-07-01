import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';

InputBorder get circularInputBorder=> OutlineInputBorder(
  borderRadius: BorderRadius.circular(25),
  borderSide: BorderSide(color: Colors.transparent),
);


InputBorder get filledDescriptionBorder => OutlineInputBorder(
  borderRadius: AppBorderRadius.brCircular12,
  borderSide: const BorderSide(
    color: Colors.transparent,
  ),
);