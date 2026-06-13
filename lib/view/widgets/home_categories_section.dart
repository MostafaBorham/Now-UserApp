import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/widgets/home_product_item.dart';
import 'package:nowdelivery_user_app/view/widgets/show_more_items_header.dart';
import 'package:nowdelivery_user_app/view/widgets/spool_carousel_slider.dart';

import '../../common/localization/lang_keys.dart';
import '../styles/text_styles.dart';

class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Column(
      spacing: 10,
      children: [
        ShowMoreItemsHeader(headerTitle: LangKeys.categoriesKey.tr()),
      ],
    );
  }
}