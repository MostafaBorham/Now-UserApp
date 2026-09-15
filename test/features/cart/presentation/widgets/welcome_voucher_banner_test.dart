import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/enums/session_types.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/welcome_voucher_banner.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';
import 'package:nowdelivery_user_app/features/promotion/viewmodel/get_welcome_voucher_vm.dart';

import '../../../../helpers/categories_test_harness.dart';



void main() {
  setUpAll(initCategoriesTestLocalization);

  const CouponModel coupon = CouponModel(code: 'WELCOME10', discountValue: 10);

  Finder codeText() =>
      find.textContaining('WELCOME10', findRichText: true);

  Override session(SessionType type) => authSessionProvider.overrideWith(
        (Ref ref) => _FakeAuthSessionVM(
          ref,
          AuthSessionState(
            sessionType: type,
            dependenciesStatus: AppDependenciesStatus.ready,
          ),
        ),
      );

  Override orders(int total) => getMyOrdersProvider.overrideWith(
        (Ref ref) => _FakeMyOrdersVM(
          AsyncValue<PaginationModel<OrderModel>>.data(
            PaginationModel<OrderModel>(
              currentPage: 1,
              lastPage: 1,
              perPage: 15,
              total: total,
              hasMore: false,
              data: const <OrderModel>[],
            ),
          ),
        ),
      );

  Override voucher(CouponModel? c) => welcomeVoucherProvider.overrideWith(
        (Ref ref) => _FakeWelcomeVoucherVM(
          c == null
              ? const AsyncValue<CouponModel>.loading()
              : AsyncValue<CouponModel>.data(c),
        ),
      );

  testWidgets('guest with a loaded coupon sees the voucher', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      const WelcomeVoucherBanner(),
      overrides: <Override>[session(SessionType.guest), voucher(coupon)],
    );

    expect(codeText(), findsOneWidget);
  });

  testWidgets('registered user with zero orders sees the voucher', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      const WelcomeVoucherBanner(),
      overrides: <Override>[
        session(SessionType.user),
        orders(0),
        voucher(coupon),
      ],
    );

    expect(codeText(), findsOneWidget);
  });

  testWidgets('registered user who already ordered does NOT see it', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      const WelcomeVoucherBanner(),
      overrides: <Override>[
        session(SessionType.user),
        orders(1),
        voucher(coupon),
      ],
    );

    expect(codeText(), findsNothing);
  });

  testWidgets('guest with no available coupon does NOT see it', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      const WelcomeVoucherBanner(),
      overrides: <Override>[session(SessionType.guest), voucher(null)],
    );

    expect(codeText(), findsNothing);
  });
}

class _FakeAuthSessionVM extends AuthSessionViewModel {
  _FakeAuthSessionVM(super.ref, AuthSessionState initial) {
    state = initial;
  }

  @override
  Future<void> resolveSession({bool awaitDependencies = false}) async {}
}

class _FakeMyOrdersVM extends GetMyOrdersViewModel {
  _FakeMyOrdersVM(AsyncValue<PaginationModel<OrderModel>> initial) {
    state = initial;
  }

  @override
  Future<void> getOrders() async {}
}

class _FakeWelcomeVoucherVM extends GetWelcomeVoucherViewModel {
  _FakeWelcomeVoucherVM(AsyncValue<CouponModel> initial) {
    state = initial;
  }

  @override
  Future<void> getWelcomeVoucher() async {}
}
