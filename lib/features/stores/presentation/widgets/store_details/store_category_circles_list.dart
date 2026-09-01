import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';

class StoreCategoryCirclesList extends ConsumerWidget {
  const StoreCategoryCirclesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final StoreModel store = ref.watch(storeProvider);
    final List<CategoryModel> categories = store.categories ?? const [];

    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text(
            LangKeys.storeCategoriesKey.tr(),
            style: AppTextStyles.style16Bold.copyWith(color: colors.tertiaryContainer),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 12,
              children: List.generate(
                categories.length,
                (int index) {
                  final CategoryModel category = categories[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => context.pushNamed(
                      AppRoutes.viewStoreCategoryProductsScreen,
                      extra: (storeId: store.id ?? 0, category: category),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.onPrimaryContainer,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: colors.neutral200),
                      ),
                      child: Text(
                        context.getLocalizedApiText(category.name),
                        style: AppTextStyles.style14Bold.copyWith(
                          color: colors.tertiaryContainer,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
