import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_themes.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_context_menu.dart';

void main() {
  testWidgets('the long-press menu is white with black labels, not the yellow '
      'surface with grey ones', (tester) async {
    final controller = TextEditingController(text: 'hello');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.getLightModeTheme(),
        home: Scaffold(
          body: TextField(
            controller: controller,
            contextMenuBuilder: appContextMenuBuilder,
          ),
        ),
      ),
    );

    await tester.longPress(find.byType(TextField));
    await tester.pumpAndSettle();

    final toolbar = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(TextSelectionToolbar),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(toolbar.color, Colors.white);

    final label = tester.renderObject<RenderParagraph>(find.text('Select all'));
    expect(label.text.style?.color, Colors.black);
  });
}
