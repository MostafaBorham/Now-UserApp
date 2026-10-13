import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_app_categories_view.dart';

import '../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('one category is shown once and stays put (BUG-002)', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      HomeAppCategoriesView(categories: <CategoryModel>[sampleCategory()]),
    );
    expect(find.text('Food'), findsOneWidget);

    // Past the 5 s auto-slide interval: nothing moves, nothing repeats.
    await tester.pump(const Duration(seconds: 6));
    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('three categories are each shown once', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      HomeAppCategoriesView(categories: sampleCategories(3)),
    );
    for (int i = 0; i < 3; i++) {
      expect(find.text('Category $i'), findsOneWidget);
    }
  });

  testWidgets('loading skeletons pulse, no image placeholder', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      const HomeAppCategoriesView(categories: <CategoryModel>[]),
    );
    expect(find.byType(AppCachedNetworkImage), findsNothing);
    expect(find.text('failedToLoadImage'), findsNothing);

    Color? disc() => (tester
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byType(LoadingPulse),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration as BoxDecoration)
        .color;
    final Color? before = disc();
    await tester.pump(LoadingPulse.period * 0.5);
    expect(disc(), isNot(before));
  });

  testWidgets('a loading image pulses like a skeleton, no spinner', (
    WidgetTester tester,
  ) async {
    // The centred disc's on-screen width.
    double centredPulse() {
      final Finder pulses = find.byType(LoadingPulse);
      return List<double>.generate(
        pulses.evaluate().length,
        (int i) => tester.getRect(pulses.at(i)).width,
      ).reduce(math.max);
    }

    await pumpCategoriesWidget(
      tester,
      const HomeAppCategoriesView(categories: <CategoryModel>[]),
    );
    final double skeleton = centredPulse();

    await pumpCategoriesWidget(
      tester,
      HomeAppCategoriesView(
        categories: <CategoryModel>[
          CategoryModel(
            id: 1,
            slug: 'food',
            name: const <String, dynamic>{'en': 'Food', 'ar': 'طعام'},
            image: 'https://example.com/food.png',
          ),
        ],
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(centredPulse(), moreOrLessEquals(skeleton));
  });

  testWidgets('a loaded category without an image shows the placeholder', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      HomeAppCategoriesView(categories: <CategoryModel>[sampleCategory()]),
    );
    expect(find.text('failedToLoadImage'), findsOneWidget);
  });

  testWidgets('a finger resting on the carousel holds it (BUG-021, QA V2)', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      HomeAppCategoriesView(categories: sampleCategories(5)),
    );
    double page() =>
        tester.widget<PageView>(find.byType(PageView)).controller!.page!;
    final double start = page();

    final TestGesture finger = await tester.startGesture(
      tester.getCenter(find.byType(PageView)),
    );
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(seconds: 1));
    expect(page(), start);

    // Cancelled rather than lifted: a lift on a category is a tap.
    await finger.cancel();
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(seconds: 1));
    expect(page(), greaterThan(start));
  });
}
