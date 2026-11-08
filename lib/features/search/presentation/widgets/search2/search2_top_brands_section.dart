import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_featured_stores_vm.dart';

class Search2TopBrandsSection extends ConsumerWidget {
  const Search2TopBrandsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PaginationModel<StoreModel>> state = ref.watch(
      getFeaturedStoresProvider,
    );
    final bool isLoading = !state.hasValue && !state.hasError;
    final List<StoreModel?> stores = isLoading
        ? List<StoreModel?>.filled(6, null)
        : state.valueOrNull?.data ?? const <StoreModel>[];
    if (stores.isEmpty) return const SizedBox.shrink();

    final AppColorScheme colors = context.colors;

    return LayoutBuilder(
      builder: (context, con) {
        final double logoSize = con.maxWidth * 0.097;
        final double cardPadding = con.maxWidth * 0.023;
        final double nameFontSize = con.maxWidth * 0.039;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                LangKeys.topBrandsKey.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.style16Bold.copyWith(
                  color: colors.neutral1200,
                  fontSize: con.maxWidth * 0.041,
                ),
              ),
            ),
            AppShimmer(
              enabled: isLoading,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: isLoading
                    ? const NeverScrollableScrollPhysics()
                    : null,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    for (int start = 0; start < stores.length; start += 2)
                      IntrinsicWidth(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 12,
                          children: [
                            for (final StoreModel? store in stores.sublist(
                              start,
                              math.min(start + 2, stores.length),
                            ))
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: store?.id == null
                                    ? null
                                    : () => context.pushNamed(
                                        AppRoutes.storeDetailsScreen,
                                        pathParameters: <String, String>{
                                          'id': '${store!.id}',
                                        },
                                        extra: store.name,
                                      ),
                                child: Container(
                                  constraints: BoxConstraints(
                                    minWidth: con.maxWidth * 0.3,
                                    maxWidth: con.maxWidth * 0.6,
                                  ),
                                  padding: EdgeInsets.all(cardPadding),
                                  decoration: BoxDecoration(
                                    color: colors.neutral1200.withValues(
                                      alpha: 0.05,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      cardPadding,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: cardPadding * 0.67,
                                    children: [
                                      if (store == null) ...[
                                        Container(
                                          width: logoSize,
                                          height: logoSize,
                                          decoration: BoxDecoration(
                                            color: colors.neutral500,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Container(
                                          width: con.maxWidth * 0.14,
                                          height: nameFontSize,
                                          decoration: BoxDecoration(
                                            color: colors.neutral500,
                                            borderRadius: BorderRadius.circular(
                                              nameFontSize / 2,
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        SizedBox.square(
                                          dimension: logoSize,
                                          child: AppCachedNetworkImage(
                                            imageUrl: store.logoUrl ?? '',
                                            width: logoSize,
                                            height: logoSize,
                                            fit: BoxFit.contain,
                                            loadingPlaceholder:
                                                const SizedBox.shrink(),
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            context.getLocalizedApiText(
                                              store.name,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.style16Medium
                                                .copyWith(
                                                  color: colors.neutral1200,
                                                  fontSize: nameFontSize,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
