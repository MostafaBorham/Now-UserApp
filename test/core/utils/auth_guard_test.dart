import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/auth_guard.dart';

/// A bare screen per route: a button, labelled with the route's name, that
/// leaves the login flow.
GoRoute _route(String name, {String path = ''}) => GoRoute(
  name: name,
  path: path.isEmpty ? '/$name' : path,
  builder: (BuildContext context, GoRouterState state) => Scaffold(
    body: TextButton(
      onPressed: () => leaveLoginFlow(context),
      child: Text(name),
    ),
  ),
);

Future<GoRouter> _pump(WidgetTester tester, String initialRoute) async {
  final GoRouter router = GoRouter(
    initialLocation: '/$initialRoute',
    routes: <RouteBase>[
      _route(AppRoutes.mainScreen),
      _route(AppRoutes.cartScreen),
      _route(AppRoutes.phoneVerificationScreen),
      _route(AppRoutes.otpVerificationScreen),
      _route(AppRoutes.completeProfileScreen),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  return router;
}

void main() {
  testWidgets('a guest who signs up from the cart is returned to the cart', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pump(tester, AppRoutes.cartScreen);
    router.pushNamed(AppRoutes.phoneVerificationScreen);
    await tester.pumpAndSettle();
    router.pushNamed(AppRoutes.otpVerificationScreen);
    await tester.pumpAndSettle();
    // What the OTP screen does for a profile that isn't complete yet.
    router.pushReplacementNamed(AppRoutes.completeProfileScreen);
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppRoutes.completeProfileScreen));
    await tester.pumpAndSettle();

    expect(router.state.topRoute?.name, AppRoutes.cartScreen);
  });

  testWidgets('profile completion reached from the splash goes to main', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pump(tester, AppRoutes.completeProfileScreen);

    await tester.tap(find.text(AppRoutes.completeProfileScreen));
    await tester.pumpAndSettle();

    expect(router.state.topRoute?.name, AppRoutes.mainScreen);
  });
}
