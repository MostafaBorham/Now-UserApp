import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_features_options_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_features_options_view/widgets/product_features_footer.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_features_options_view/widgets/product_features_header.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_features_options_view/widgets/product_features_sections/product_features_sections.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_features_options_view/widgets/product_features_sidebar/product_features_sidebar.dart';

Future<void> showProductFeaturesOptionsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext sheetContext) => const ProductFeaturesOptionsView(),
  );
}

class ProductFeaturesOptionsView extends ConsumerWidget {
  const ProductFeaturesOptionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProductFeaturesOptionsState state = ref.watch(
      productFeaturesOptionsProvider,
    );
    final ProductFeaturesOptionsNotifier viewModel = ref.read(
      productFeaturesOptionsProvider.notifier,
    );
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.73,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            ProductFeaturesHeader(onClose: context.pop),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    ProductFeaturesSidebar(
                      selectedIndex: state.selectedSectionIndex,
                      onSelected: viewModel.selectSection,
                    ),
                    Expanded(
                      child: ProductFeaturesSections(
                        scrollSpy: viewModel.sectionsScrollSpy,
                        collapsedSectionIndexes: state.collapsedSectionIndexes,
                        selectedOptionIndexes: state.selectedOptionIndexes,
                        onSectionToggled: viewModel.toggleSection,
                        onOptionSelected: viewModel.selectOption,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ProductFeaturesFooter(
              onConfirm: context.pop,
              onCancel: context.pop,
            ),
          ],
        ),
      ),
    );
  }
}
