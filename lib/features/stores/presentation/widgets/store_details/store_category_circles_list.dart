import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';

class StoreCategoryCirclesList extends ConsumerWidget {
  const StoreCategoryCirclesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final StoreModel store = ref.watch(storeProvider);
    final List<CategoryModel> categories = store.categories ?? const [];

    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) => InkWell(
          onTap: () => context.pushNamed(
            AppRoutes.viewStoreCategoryProductsScreen,
            extra: (storeId: store.id ?? 0, category: categories[index]),
          ),
          child: SizedBox(
            width: 80,
            child: Column(
              spacing: 8,
              children: [
                CircularBrandLogo(
                  radius: 40,
                  logoUrl: categories[index].image ?? '',
                ),
                AutoSizeText(
                  context.getLocalizedApiText(categories[index].name),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: AppTextStyles.style14SemiBold.copyWith(
                    color: colors.onSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
