import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';

import '../../../../helpers/categories_test_harness.dart';

// QA-003 A1: the title said "Failed to connect to the server" whatever went
// wrong, even above the server's own answer.
void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('offline is titled as offline', (WidgetTester tester) async {
    await pumpCategoriesWidget(
      tester,
      const ServerConnectionErrorWidget(
        message: LangKeys.noInternetConnectionKey,
      ),
    );
    expect(find.text(LangKeys.noInternetTitleKey), findsOneWidget);
  });

  testWidgets('anything else is a page that failed to load', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      const ServerConnectionErrorWidget(message: 'Coupon expired'),
    );
    expect(find.text(LangKeys.loadFailedTitleKey), findsOneWidget);
    expect(find.text(LangKeys.serverConnectionFailedKey), findsNothing);
  });

  // A8: a deleted order, product or store is an empty state, with no Retry.
  testWidgets('a gone item reads as empty, not as a failure', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      ServerConnectionErrorWidget(
        message: LangKeys.productUnavailableKey,
        onRetry: () {},
      ),
    );
    expect(find.text(LangKeys.productUnavailableKey), findsOneWidget);
    expect(find.text(LangKeys.retryKey), findsNothing);
  });
}
