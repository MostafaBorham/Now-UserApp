import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_store_info_view/widgets/product_store_info_card.dart';

class ProductStoreInfoView extends StatelessWidget {
  const ProductStoreInfoView({super.key, required this.store, this.onTap});

  final StoreModel store;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Text(
          LangKeys.sellerKey.tr(),
          style: AppTextStyles.style16Bold.copyWith(
            color: context.colors.black,
            height: 1.5,
          ),
        ),
        ProductStoreInfoCard(store: store, onTap: onTap),
      ],
    );
  }
}
