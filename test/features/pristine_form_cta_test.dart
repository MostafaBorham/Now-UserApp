import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/selectable_rating_stars.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_rating_model.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/screens/order_rating_screen.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/personal_information_data.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';
import 'package:nowdelivery_user_app/features/personal_information/presentation/screens/edit_information_screen.dart';
import 'package:nowdelivery_user_app/features/personal_information/presentation/widgets/primary_button.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';
import 'package:nowdelivery_user_app/features/support/presentation/screens/file_complaint_screen.dart';

import '../helpers/categories_test_harness.dart';

/// A form's main button waits for the user to give it something to send:
/// an untouched form used to submit empty or unchanged data.
void main() {
  setUpAll(initCategoriesTestLocalization);

  /// Labels render as raw keys on the test surface and can overflow; only
  /// layout overflow is tolerated.
  void ignoreOverflow(WidgetTester tester) {
    for (
      Object? ex = tester.takeException();
      ex != null;
      ex = tester.takeException()
    ) {
      expect(ex.toString(), contains('overflow'));
    }
  }

  bool appButtonDisabled(WidgetTester tester, String titleKey) => tester
      .widget<PrimaryAppButton>(find.widgetWithText(PrimaryAppButton, titleKey))
      .isDisabled;

  testWidgets('profile: Save waits for a change and goes back when undone', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesScreen(
      tester,
      const EditInformationScreen(),
      overrides: <Override>[
        getProfileProvider.overrideWith((Ref ref) => _LoadedProfile()),
      ],
    );
    ignoreOverflow(tester);

    bool saveDisabled() => tester
        .widget<PrimaryButton>(
          find.widgetWithText(PrimaryButton, LangKeys.saveKey),
        )
        .isDisabled;
    final Finder nameField = find.byWidgetPredicate(
      (Widget w) => w is TextField && w.controller?.text == 'Sara Ali',
    );

    expect(saveDisabled(), isTrue);

    await tester.enterText(nameField, 'Sara A. Ali');
    await tester.pump();
    ignoreOverflow(tester);
    expect(saveDisabled(), isFalse);

    await tester.enterText(find.byType(TextField).first, 'Sara Ali');
    await tester.pump();
    ignoreOverflow(tester);
    expect(saveDisabled(), isTrue);
  });

  testWidgets('rating: Submit waits for the first star', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesScreen(
      tester,
      const OrderRatingScreen(
        order: OrderModel(
          id: 77,
          rating: OrderRatingModel(
            canRate: true,
            products: <RatedProductModel>[
              RatedProductModel(
                productId: 5,
                name: <String, dynamic>{'en': 'Phone'},
              ),
            ],
            vendor: RatedSubjectModel(
              id: 3,
              name: <String, dynamic>{'en': 'Store'},
            ),
          ),
        ),
      ),
    );
    ignoreOverflow(tester);

    expect(appButtonDisabled(tester, LangKeys.submitRatingKey), isTrue);

    final Finder firstStars = find.byType(SelectableRatingStars).first;
    await tester.ensureVisible(firstStars);
    await tester.tapAt(tester.getCenter(firstStars));
    await tester.pump();
    ignoreOverflow(tester);

    expect(appButtonDisabled(tester, LangKeys.submitRatingKey), isFalse);
  });

  testWidgets('complaint: Submit waits for a description', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesScreen(
      tester,
      const FileComplaintScreen(order: OrderModel(id: 9, uuid: 'u-9')),
    );
    ignoreOverflow(tester);

    expect(appButtonDisabled(tester, LangKeys.submitComplaintKey), isTrue);

    await tester.enterText(find.byType(TextField).first, '   ');
    await tester.pump();
    expect(appButtonDisabled(tester, LangKeys.submitComplaintKey), isTrue);

    await tester.enterText(find.byType(TextField).first, 'Arrived cold');
    await tester.pump();
    ignoreOverflow(tester);
    expect(appButtonDisabled(tester, LangKeys.submitComplaintKey), isFalse);
  });
}

class _LoadedProfile extends GetProfileViewModel {
  _LoadedProfile() {
    state = const AsyncValue<PersonalInformationData>.data(
      PersonalInformationData(
        profile: ProfileModel(
          id: 1,
          fullName: 'Sara Ali',
          email: 'sara@example.com',
          phone: '+966500000000',
          gender: 'female',
          birthday: '1995-04-02',
        ),
      ),
    );
  }

  @override
  Future<void> getProfile() async {}
}
