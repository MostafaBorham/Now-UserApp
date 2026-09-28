import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';
import 'package:nowdelivery_user_app/features/home/presentation/utils/open_category.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';

import '../helpers/categories_test_harness.dart';

class _FakeFeed extends GetHomeSectionsViewModel {
  _FakeFeed(List<HomeSectionModel> sections) {
    state = AsyncValue<List<HomeSectionModel>>.data(sections);
  }
}

/// Pumps a two-route app whose home button opens a category through
/// [openHomeCategory]; category details just prints the slug it was opened by.
Future<void> _pump(
  WidgetTester tester, {
  int? id,
  String? slug,
  List<CategoryModel> appCategories = const <CategoryModel>[],
  List<CategoryModel> feedCategories = const <CategoryModel>[],
}) async {
  final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) => TextButton(
            onPressed: () => openHomeCategory(context, ref, id: id, slug: slug),
            child: const Text('open'),
          ),
        ),
      ),
      GoRoute(
        name: AppRoutes.categoryDetailsScreen,
        path: '/${AppRoutes.categoryDetailsScreen}/:slug',
        builder: (context, state) =>
            Text('opened ${state.pathParameters['slug']}'),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        overrideAppCategories(
          AsyncValue.data(pageOf<CategoryModel>(appCategories)),
        ),
        getHomeSectionsProvider.overrideWith(
          (Ref ref) => _FakeFeed(<HomeSectionModel>[
            HomeSectionModel(type: 'categories', categories: feedCategories),
          ]),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an id opens the loaded category with that id', (tester) async {
    await _pump(
      tester,
      id: 3,
      appCategories: <CategoryModel>[sampleCategory(id: 3, slug: 'fashion')],
    );

    expect(find.text('opened fashion'), findsOneWidget);
  });

  testWidgets('the feed\'s own categories are searched too', (tester) async {
    await _pump(
      tester,
      id: 7,
      feedCategories: <CategoryModel>[sampleCategory(id: 7, slug: 'toys')],
    );

    expect(find.text('opened toys'), findsOneWidget);
  });

  testWidgets('a slug is used as is', (tester) async {
    await _pump(tester, id: 3, slug: 'direct');

    expect(find.text('opened direct'), findsOneWidget);
  });

  testWidgets('an id nothing loaded knows stays put', (tester) async {
    await _pump(
      tester,
      id: 99,
      appCategories: <CategoryModel>[sampleCategory(id: 3, slug: 'fashion')],
    );

    expect(find.text('open'), findsOneWidget);
    expect(find.textContaining('opened'), findsNothing);
  });
}
