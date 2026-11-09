import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/constants.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/cancel_order_vm.dart';
import 'package:nowdelivery_user_app/features/tracking_order/presentation/components/cancel_order_bottom_sheet.dart';

import '../../helpers/categories_test_harness.dart';

const _orderUuid = 'test-order';

class _TestCancellation extends CancelOrderViewModel {
  _TestCancellation(Ref ref) : super(ref: ref, orderUuid: _orderUuid);

  Completer<String?>? pending;
  int attempts = 0;
  String? submittedReason;

  @override
  Future<String?> cancelOrder({required String reason}) async {
    attempts++;
    submittedReason = reason;
    state = const AsyncValue<void>.loading();
    pending = Completer<String?>();
    final error = await pending!.future;
    state = error == null
        ? const AsyncValue<void>.data(null)
        : AsyncValue<void>.error(error, StackTrace.current);
    return error;
  }
}

void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets(
    'requires a reason and preserves it when cancellation is retried',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 720);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);

      late _TestCancellation cancellation;
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: LocalizationConstants.supportedLocales,
          path: LocalizationConstants.languagesPath,
          startLocale: LocalizationConstants.englishLocale,
          child: ProviderScope(
            overrides: [
              cancelOrderProvider(
                _orderUuid,
              ).overrideWith((ref) => cancellation = _TestCancellation(ref)),
            ],
            child: Builder(
              builder: (context) => MaterialApp(
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
                home: Scaffold(
                  body: Builder(
                    builder: (context) => TextButton(
                      onPressed: () => CancelOrderBottomSheet.show(
                        context,
                        orderUuid: _orderUuid,
                        orderNumber: '123',
                        itemsCount: 2,
                        amount: '50',
                      ),
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final confirm = find.widgetWithText(
        PrimaryAppButton,
        'Yes, Cancel Order',
      );
      expect(tester.widget<PrimaryAppButton>(confirm).onTap, isNull);

      final preset = find.text(LangKeys.cancelReasonNoLongerNeededKey.tr());
      await tester.ensureVisible(preset);
      await tester.tap(preset);
      await tester.pumpAndSettle();
      expect(tester.widget<PrimaryAppButton>(confirm).onTap, isNotNull);

      final other = find.text('Other');
      await tester.ensureVisible(other);
      await tester.tap(other);
      await tester.pumpAndSettle();

      final otherReason = find.byType(TextFormField);
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );
      final fieldBounds = tester.getRect(otherReason);
      final scrollBounds = tester.getRect(find.byType(SingleChildScrollView));
      expect(fieldBounds.top, greaterThanOrEqualTo(scrollBounds.top));
      expect(fieldBounds.bottom, lessThanOrEqualTo(scrollBounds.bottom));

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      await tester.ensureVisible(otherReason);
      await tester.enterText(otherReason, ' short ');
      await tester.pumpAndSettle();
      expect(tester.widget<PrimaryAppButton>(confirm).onTap, isNull);
      expect(confirm.hitTestable(), findsOneWidget);

      await tester.enterText(otherReason, '  No longer needed  ');
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      await tester.tap(confirm);
      await tester.pump();
      expect(cancellation.attempts, 1);
      expect(cancellation.submittedReason, 'No longer needed');
      expect(
        tester
            .widget<PrimaryAppButton>(find.byType(PrimaryAppButton))
            .isLoading,
        isTrue,
      );
      await tester.tap(find.text('Keep Order'));
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      expect(find.byType(CancelOrderBottomSheet), findsOneWidget);

      cancellation.pending!.complete(LangKeys.noInternetConnectionKey);
      await tester.pumpAndSettle();
      expect(find.text(LangKeys.noInternetConnectionKey.tr()), findsOneWidget);
      expect(find.text('  No longer needed  '), findsOneWidget);

      await tester.tap(confirm);
      await tester.pump();
      expect(cancellation.attempts, 2);
      cancellation.pending!.complete(null);
      await tester.pumpAndSettle();
      expect(find.text('Your order has been canceled'), findsOneWidget);
      expect(confirm, findsNothing);
    },
  );
}
