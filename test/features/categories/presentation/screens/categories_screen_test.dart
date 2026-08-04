import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/screens/categories_screen.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/categories/category_card.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/categories/category_card_shimmer.dart';

import '../../../../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('first-page loading shows skeleton cards, no real cards',
      (WidgetTester tester) async {
    await pumpCategoriesScreen(
      tester,
      const CategoriesScreen(),
      overrides: <Override>[
        overrideAppCategories(
          const AsyncValue<PaginationModel<CategoryModel>>.loading(),
        ),
      ],
    );

    expect(find.byType(CategoryCardShimmer), findsWidgets);
    expect(find.byType(CategoryCard), findsNothing);
  });

  testWidgets('loaded page renders a CategoryCard per item',
      (WidgetTester tester) async {
    await pumpCategoriesScreen(
      tester,
      const CategoriesScreen(),
      overrides: <Override>[
        overrideAppCategories(
          AsyncValue<PaginationModel<CategoryModel>>.data(
            pageOf<CategoryModel>(sampleCategories(3)),
          ),
        ),
      ],
    );

    expect(find.byType(CategoryCard), findsNWidgets(3));
    expect(find.text('Category 0'), findsOneWidget);
    expect(find.byType(CategoryCardShimmer), findsNothing);
  });

  testWidgets('an empty first page shows the no-items widget',
      (WidgetTester tester) async {
    await pumpCategoriesScreen(
      tester,
      const CategoriesScreen(),
      overrides: <Override>[
        overrideAppCategories(
          AsyncValue<PaginationModel<CategoryModel>>.data(
            pageOf<CategoryModel>(const <CategoryModel>[]),
          ),
        ),
      ],
    );

    expect(find.byType(NoItemsWidget), findsOneWidget);
    expect(find.byType(CategoryCard), findsNothing);
  });

  testWidgets('a failed first page shows the error widget',
      (WidgetTester tester) async {
    await pumpCategoriesScreen(
      tester,
      const CategoriesScreen(),
      overrides: <Override>[
        overrideAppCategories(
          AsyncValue<PaginationModel<CategoryModel>>.error(
            'serverConnectionFailed',
            StackTrace.empty,
          ),
        ),
      ],
    );

    expect(find.byType(ServerConnectionErrorWidget), findsOneWidget);
    expect(find.byType(CategoryCard), findsNothing);
  });
}
