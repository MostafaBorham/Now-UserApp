import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/support/circular_support_icon.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/faq_model.dart';
import 'package:nowdelivery_user_app/features/support/presentation/screens/support_faqs_screen.dart';

import '../../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('the support icon spins until its tap completes, ignoring taps', (
    tester,
  ) async {
    Completer<void> load = Completer<void>();
    int taps = 0;
    await pumpCategoriesWidget(
      tester,
      CircularSupportIcon(
        onTap: () {
          taps++;
          return load.future;
        },
      ),
    );

    await tester.tap(find.byType(CircularSupportIcon));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(CircularSupportIcon));
    await tester.pump();
    expect(taps, 1);

    load.complete();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    load = Completer<void>()..complete();
    await tester.tap(find.byType(CircularSupportIcon));
    await tester.pump();
    expect(taps, 2);
  });

  testWidgets('the FAQs it is handed are listed with "Other" last', (
    tester,
  ) async {
    await pumpCategoriesScreen(
      tester,
      const SupportFaqsScreen(
        faqs: <FaqModel>[
          FaqModel(id: 1, question: <String, dynamic>{'en': 'Where is my order?'}),
        ],
      ),
    );

    final double faq = tester.getTopLeft(find.text('Where is my order?')).dy;
    final double other = tester.getTopLeft(find.text(LangKeys.otherKey.tr())).dy;
    expect(other, greaterThan(faq));
  });
}
