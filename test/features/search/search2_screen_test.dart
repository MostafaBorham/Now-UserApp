import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';
import 'package:nowdelivery_user_app/features/search/presentation/screens/search2_screen.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search_placeholder_view.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search_results_view.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_featured_stores_vm.dart';

import '../../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('searches categories and opens the result by slug', (
    tester,
  ) async {
    final List<String> terms = [];
    await pumpCategoriesScreen(
      tester,
      const Search2Screen(),
      overrides: [
        getFeaturedStoresProvider.overrideWith((ref) => _FeaturedStores()),
        searchAppCategoriesProvider.overrideWith((ref, term) {
          terms.add(term);
          return _CategoryResults();
        }),
      ],
      destinationRoutes: [
        GoRoute(
          name: AppRoutes.categoryDetailsScreen,
          path: '/category-details/:slug',
          builder: (context, state) =>
              Scaffold(body: Text('Category: ${state.pathParameters['slug']}')),
        ),
      ],
    );
    expect(find.byType(SearchPlaceholderView), findsOneWidget);
    expect(find.text('Featured brand'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Laptop');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(SearchResultsView), findsOneWidget);
    expect(tester.testTextInput.isVisible, isTrue);
    expect(terms, ['Laptop']);

    await tester.enterText(find.byType(TextField), 'Laptops');
    await tester.pump(const Duration(seconds: 1));
    expect(terms, ['Laptop', 'Laptops']);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    await tester.pump();
    final Finder placeholderField = find.descendant(
      of: find.byType(SearchPlaceholderView),
      matching: find.byType(TextField),
    );
    await tester.enterText(placeholderField, 'Tablets');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );
    expect(tester.testTextInput.isVisible, isTrue);
    expect(terms, ['Laptop', 'Laptops', 'Tablets']);

    await tester.tap(find.text('Laptop category'));
    await tester.pumpAndSettle();
    expect(find.text('Category: laptops'), findsOneWidget);
  });
}

class _CategoryResults extends GetAppCategoriesViewModel {
  _CategoryResults() {
    state = AsyncValue.data(
      pageOf<CategoryModel>([
        const CategoryModel(slug: 'laptops', name: {'en': 'Laptop category'}),
      ]),
    );
  }
}

class _FeaturedStores extends GetFeaturedStoresViewModel {
  _FeaturedStores() {
    state = AsyncValue.data(
      pageOf<StoreModel>([
        const StoreModel(id: 1, name: {'en': 'Featured brand'}),
      ]),
    );
  }
}
