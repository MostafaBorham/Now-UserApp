import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/enums/session_types.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/dialogs/app_custom_alert_dialog.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/logout_vm.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/personal_information_data.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';
import 'package:nowdelivery_user_app/features/promotion/viewmodel/get_welcome_voucher_vm.dart';
import 'package:nowdelivery_user_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:nowdelivery_user_app/features/settings/presentation/widgets/settings_guest_view.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_info_vm.dart';

import '../../helpers/categories_test_harness.dart';

class _Session extends AuthSessionViewModel {
  _Session(super.ref) {
    state = state.copyWith(sessionType: SessionType.user);
  }

  void becomeGuest() {
    state = state.copyWith(sessionType: SessionType.guest);
  }
}

class _Logout extends LogoutViewModel {
  _Logout(super.ref);

  final Completer<void> finish = Completer<void>();

  @override
  Future<void> logout() async {
    state = const AsyncValue.loading();
    await finish.future;
    state = const AsyncValue.data(unit);
  }
}

class _Wallet extends GetWalletInfoViewModel {
  @override
  Future<void> getWalletInfo() async {
    setWallet(const WalletModel(balance: 23.45));
  }
}

class _WelcomeVoucher extends GetWelcomeVoucherViewModel {
  void publish(String code) {
    state = AsyncValue.data(CouponModel(code: code));
  }
}

void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('guest banner only appears with a welcome voucher', (
    WidgetTester tester,
  ) async {
    final _WelcomeVoucher voucher = _WelcomeVoucher();
    await pumpCategoriesWidget(
      tester,
      const SettingsScreen(),
      overrides: [welcomeVoucherProvider.overrideWith((_) => voucher)],
    );

    expect(find.text(welcomeVoucherCode), findsNothing);
    voucher.publish(welcomeVoucherCode);
    await tester.pumpAndSettle();
    expect(find.text(welcomeVoucherCode), findsOneWidget);
  });

  testWidgets('logout returns to onboarding after switching to guest', (
    WidgetTester tester,
  ) async {
    late _Session session;
    late _Logout logout;
    await pumpCategoriesScreen(
      tester,
      const SettingsScreen(),
      overrides: [
        authSessionProvider.overrideWith((ref) => session = _Session(ref)),
        logoutProvider.overrideWith((ref) => logout = _Logout(ref)),
        getProfileProvider.overrideWith(
          (_) => GetProfileViewModel()
            ..setProfileData(
              const PersonalInformationData(
                profile: ProfileModel(fullName: 'Test User'),
              ),
            ),
        ),
        getWalletInfoProvider.overrideWith((_) => _Wallet()),
        welcomeVoucherProvider.overrideWith(
          (_) => GetWelcomeVoucherViewModel(),
        ),
      ],
      destinationRoutes: [
        GoRoute(
          name: AppRoutes.onBoardingScreen,
          path: '/onboarding',
          builder: (_, _) => const Scaffold(body: Text('Onboarding screen')),
        ),
        GoRoute(
          name: AppRoutes.walletScreen,
          path: '/wallet',
          builder: (_, _) => const Scaffold(body: Text('Wallet screen')),
        ),
      ],
    );

    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('23.45'), findsOneWidget);
    await tester.tap(find.text(LangKeys.walletBalanceKey));
    await tester.pumpAndSettle();
    expect(find.text('Wallet screen'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    final Finder logoutRow = find.text(LangKeys.logout);
    await tester.ensureVisible(logoutRow);
    await tester.pumpAndSettle();
    await tester.tap(logoutRow);
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .descendant(
            of: find.byType(AppCustomAlertDialog),
            matching: find.text(LangKeys.logout),
          )
          .last,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AppCustomAlertDialog), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    session.becomeGuest();
    await tester.pumpAndSettle();
    expect(find.byType(SettingsGuestView), findsOneWidget);
    expect(find.text('23.45'), findsNothing);
    logout.finish.complete();
    await tester.pumpAndSettle();
    expect(find.text('Onboarding screen'), findsOneWidget);
  });
}
