import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_themes.dart';
import 'package:nowdelivery_user_app/features/personal_information/presentation/widgets/profile_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SharedPrefManager.init();
  });

  Future<void> pumpAvatar(WidgetTester tester, String? imageUrl) async {
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, _) => Scaffold(
            body: Center(
              child: ProfileAvatar(imageUrl: imageUrl, fullScreenOnTap: true),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppThemes.getLightModeTheme(),
        routerConfig: router,
      ),
    );
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets(
    'the avatar opens full screen and the close button dismisses it',
    (WidgetTester tester) async {
      await pumpAvatar(tester, 'https://example.com/avatar.png');

      await tapAndSettle(tester, find.byType(ProfileAvatar));
      expect(find.byType(InteractiveViewer), findsOneWidget);

      await tapAndSettle(tester, find.byIcon(Icons.close));
      expect(find.byType(InteractiveViewer), findsNothing);
    },
  );

  testWidgets('the placeholder avatar does not open', (
    WidgetTester tester,
  ) async {
    await pumpAvatar(tester, null);

    await tapAndSettle(tester, find.byType(ProfileAvatar));
    expect(find.byType(InteractiveViewer), findsNothing);
  });
}
