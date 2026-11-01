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

  testWidgets('the avatar opens full screen and the close button dismisses it', (
    WidgetTester tester,
  ) async {
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, _) => Scaffold(
            body: TextButton(
              onPressed: () => showProfileAvatarFullScreen(
                context,
                'https://example.com/avatar.png',
              ),
              child: const Text('open'),
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

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(InteractiveViewer), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });
}
