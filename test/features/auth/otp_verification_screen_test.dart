import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/verify_otp_vm.dart';

import '../../helpers/categories_test_harness.dart';

const OtpVerificationScreen _screen = OtpVerificationScreen(
  phoneNumber: '+966501234567',
  retryAfterSeconds: 0,
);

void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('Back does nothing while the code is verified (BUG-007)', (
    WidgetTester tester,
  ) async {
    await pumpSheetViaRouter(
      tester,
      _screen,
      overrides: <Override>[
        verifyOtpProvider.overrideWith((Ref ref) => _Verifying(ref)),
      ],
    );
    expect(find.byType(OtpVerificationScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(OtpVerificationScreen), findsOneWidget);
    expect(find.text('__home__'), findsNothing);
  });

  testWidgets('pasting a clipboard with no digits keeps the typed code '
      '(BUG-006)', (WidgetTester tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async => call.method == 'Clipboard.getData'
          ? <String, dynamic>{'text': 'hi'}
          : null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpSheetViaRouter(tester, _screen);

    await tester.enterText(find.byType(TextField), '12');
    await tester.tap(find.text(LangKeys.pasteCodeKey));
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '12',
    );
  });
}

class _Verifying extends VerifyOtpViewModel {
  _Verifying(super.ref) {
    state = const AsyncValue.loading();
  }
}
