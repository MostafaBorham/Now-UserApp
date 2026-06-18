import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/categories/category_product_item.dart';
import 'package:nowdelivery_user_app/view/widgets/categories/category_store_item.dart';
import 'package:nowdelivery_user_app/view/widgets/home/home_offers_item.dart';
import 'package:nowdelivery_user_app/view/widgets/home/home_store_list_item.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/tab_bars/custom_button_tab_bar.dart';

class CategoryStoreTabView extends StatelessWidget {
  const CategoryStoreTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, con) {
        return ListView.separated(
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) => SizedBox(
            height: con.maxHeight * 0.37,
            child: CategoryStoreItem(),
          ),
          separatorBuilder: (context, index) => 20.hSpace,
          itemCount: 3,
        );
      },
    );
  }
}