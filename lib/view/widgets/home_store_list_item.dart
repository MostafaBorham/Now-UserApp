import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../assets/assets.gen.dart';
import '../styles/app_border_radius.dart';
import '../styles/text_styles.dart';
import 'circular_brand_logo.dart';
import 'current_price_with_currency.dart';
import 'previous_price_with_currency.dart';
import 'shared/reverse_widget.dart';

class HomeStoreListItem extends StatelessWidget {
  const HomeStoreListItem({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 3,
      color: Colors.red,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.brCircular16,
      ),

    );
  }
}
