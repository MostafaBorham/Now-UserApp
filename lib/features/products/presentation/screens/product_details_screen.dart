import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_body.dart';

/// Standalone host for callers that explicitly embed a full details screen.
/// Product links use the modal ProductDetailsOverlay route instead.
class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.productSlug});
  final String productSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: AppWavedView(
      bodyPadding: const EdgeInsets.only(bottom: 12),
      body: ProductDetailsBody(productSlug: productSlug),
      appBarTitle: LangKeys.productDetailsKey.tr(),
      hasCartIcon: true,
      onCartTap: () {
        ref.read(mainTabIndexProvider.notifier).state = 2;
        final router = GoRouter.of(context);
        while (router.canPop()) {
          router.pop();
        }
      },
    ),
  );
}
