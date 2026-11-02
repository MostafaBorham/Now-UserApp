import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/app_info_model.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/privacy_model.dart';
import 'package:nowdelivery_user_app/features/settings/presentation/screens/privacy_screen.dart';
import 'package:nowdelivery_user_app/features/settings/viewmodel/get_app_info_vm.dart';

import '../../helpers/categories_test_harness.dart';

/// App info frozen in [value]; a fetch only counts.
class _FakeAppInfo extends GetAppInfoViewModel {
  _FakeAppInfo(AsyncValue<AppInfoModel> value) {
    state = value;
  }

  int fetches = 0;

  @override
  Future<void> getAppInfo() async => fetches++;
}

const AppInfoModel _loaded = AppInfoModel(
  content: PrivacyModel(terms: <String, dynamic>{'en': 'Terms body'}),
);

void main() {
  setUpAll(initCategoriesTestLocalization);

  Future<_FakeAppInfo> pumpScreen(
    WidgetTester tester,
    AsyncValue<AppInfoModel> value,
  ) async {
    final _FakeAppInfo fake = _FakeAppInfo(value);
    await pumpCategoriesScreen(
      tester,
      const PrivacyPolicyScreen(),
      overrides: <Override>[getAppInfoProvider.overrideWith((Ref ref) => fake)],
    );
    await tester.pump(const Duration(seconds: 1));
    return fake;
  }

  testWidgets('opening the screen refetches the preloaded content', (
    WidgetTester tester,
  ) async {
    final _FakeAppInfo fake = await pumpScreen(
      tester,
      const AsyncValue<AppInfoModel>.data(_loaded),
    );

    expect(fake.fetches, 1);
    expect(find.text('Terms body'), findsOneWidget);
  });

  testWidgets('a load already in flight is not fetched twice', (
    WidgetTester tester,
  ) async {
    final _FakeAppInfo fake = await pumpScreen(
      tester,
      const AsyncValue<AppInfoModel>.loading(),
    );

    expect(fake.fetches, 0);
  });

  testWidgets('pulling down refetches', (WidgetTester tester) async {
    final _FakeAppInfo fake = await pumpScreen(
      tester,
      const AsyncValue<AppInfoModel>.data(_loaded),
    );

    await tester.fling(find.text('Terms body'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(fake.fetches, 2);
  });
}
