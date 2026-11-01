import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_themes.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/features/support_chat/components/chat_bubble.dart';
import 'package:nowdelivery_user_app/features/support_chat/data/models/support_chat_message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SharedPrefManager.init();
  });

  SupportChatAttachmentModel image(int i) => SupportChatAttachmentModel(
    url: 'https://example.com/$i.png',
    name: '$i.png',
    isImage: true,
  );

  Future<void> pumpBubble(
    WidgetTester tester,
    List<SupportChatAttachmentModel> attachments,
  ) async {
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, _) => Scaffold(
            body: ChatBubble(
              message: ChatMessage(
                text: '',
                time: '11:15',
                attachments: attachments,
              ),
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

  List<Size> tileSizes(WidgetTester tester) => tester
      .widgetList<AppCachedNetworkImage>(find.byType(AppCachedNetworkImage))
      .map((AppCachedNetworkImage tile) => Size(tile.width!, tile.height!))
      .toList();

  testWidgets('one photo is a 200 px square', (WidgetTester tester) async {
    await pumpBubble(tester, <SupportChatAttachmentModel>[image(1)]);

    expect(tileSizes(tester), <Size>[const Size(200, 200)]);
  });

  testWidgets('three photos: two squares, then one spanning the row', (
    WidgetTester tester,
  ) async {
    await pumpBubble(tester, <SupportChatAttachmentModel>[
      image(1),
      image(2),
      image(3),
    ]);

    expect(tileSizes(tester), <Size>[
      const Size(98, 98),
      const Size(98, 98),
      const Size(200, 98),
    ]);
    final Finder tiles = find.byType(AppCachedNetworkImage);
    expect(
      tester.getTopLeft(tiles.at(1)).dy,
      tester.getTopLeft(tiles.at(0)).dy,
    );
    expect(
      tester.getTopLeft(tiles.at(2)).dy,
      greaterThan(tester.getTopLeft(tiles.at(0)).dy),
    );
    // A loaded image centres itself in all the width it's offered, so a tile
    // that isn't held to its size fills the row alone. Images can't load
    // here — the error placeholder hides that — so check the size is fixed.
    expect(
      tester
          .renderObjectList<RenderBox>(tiles)
          .every((RenderBox tile) => tile.constraints.isTight),
      isTrue,
    );
  });

  testWidgets('a file stays a named row beside the photo grid', (
    WidgetTester tester,
  ) async {
    await pumpBubble(tester, <SupportChatAttachmentModel>[
      image(1),
      const SupportChatAttachmentModel(
        url: 'https://example.com/receipt.pdf',
        name: 'receipt.pdf',
        isImage: false,
      ),
    ]);

    expect(find.byType(AppCachedNetworkImage), findsOneWidget);
    expect(find.text('receipt.pdf'), findsOneWidget);
  });

  testWidgets('tapping a photo opens it full screen', (
    WidgetTester tester,
  ) async {
    await pumpBubble(tester, <SupportChatAttachmentModel>[image(1), image(2)]);

    // The tile's detector, not the image: a failed load doesn't hit-test.
    await tester.tap(
      find
          .ancestor(
            of: find.byType(AppCachedNetworkImage).at(1),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final Finder viewer = find.byType(InteractiveViewer);
    expect(viewer, findsOneWidget);
    expect(
      tester
          .widget<AppCachedNetworkImage>(
            find.descendant(
              of: viewer,
              matching: find.byType(AppCachedNetworkImage),
            ),
          )
          .imageUrl,
      'https://example.com/2.png',
    );
  });
}
