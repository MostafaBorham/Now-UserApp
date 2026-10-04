import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/constants.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/presentation/utils/address_line.dart';

import '../../helpers/categories_test_harness.dart';

class _ArabicLoader extends AssetLoader {
  const _ArabicLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      <String, dynamic>{'floorValue': 'الطابق {}', 'apartmentValue': 'شقة {}'};
}

/// Builds [address]'s line in Arabic.
Future<String> _arabicLine(WidgetTester tester, AddressModel address) async {
  late String line;
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: LocalizationConstants.supportedLocales,
      path: LocalizationConstants.languagesPath,
      startLocale: LocalizationConstants.arabicLocale,
      assetLoader: const _ArabicLoader(),
      child: Builder(
        builder: (BuildContext context) => MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          home: Builder(
            builder: (BuildContext context) {
              line = addressLine(context, address);
              return const SizedBox();
            },
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  return line;
}

void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('an Arabic line reads in Arabic, without the city twice '
      '(BUG-023, BUG-024)', (WidgetTester tester) async {
    expect(
      await _arabicLine(
        tester,
        const AddressModel(
          street: 'شارع الملك فهد',
          buildingNumber: 'برج النور',
          floor: '3',
          apartment: '12',
          area: 'العليا - الرياض',
          city: 'الرياض',
        ),
      ),
      'شارع الملك فهد، برج النور، الطابق 3، شقة 12، العليا - الرياض',
    );
  });

  testWidgets('a Work address shows its company name bare', (
    WidgetTester tester,
  ) async {
    expect(
      await _arabicLine(
        tester,
        const AddressModel(
          label: <String, dynamic>{'en': 'Work', 'ar': 'العمل'},
          apartment: 'أكمي',
          floor: '5',
          city: 'جدة',
        ),
      ),
      'الطابق 5، أكمي، جدة',
    );
  });
}
