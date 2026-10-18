import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A `TextField(`, `TextFormField(` or `SelectableText(` constructor call.
/// The lookbehind keeps `CupertinoTextField(` and `_MyTextField(` out.
final RegExp _field = RegExp(
  r'(?<![A-Za-z0-9_.])(TextField|TextFormField|SelectableText)\(',
);

void main() {
  test('every text field passes contextMenuBuilder: appContextMenuBuilder', () {
    final List<String> missing = <String>[];

    for (final File file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final String source = file.readAsStringSync();

      for (final RegExpMatch match in _field.allMatches(source)) {
        // ponytail: plain paren counting, blind to parens inside strings and
        // comments. Good enough for constructor arguments; parse with
        // package:analyzer if a field's arguments ever fool it.
        int depth = 0;
        int end = match.end - 1;
        for (; end < source.length; end++) {
          if (source[end] == '(') depth++;
          if (source[end] == ')' && --depth == 0) break;
        }
        final String call = source.substring(match.start, end);
        if (!call.contains('contextMenuBuilder: appContextMenuBuilder')) {
          final int line =
              '\n'.allMatches(source.substring(0, match.start)).length + 1;
          missing.add('${file.path}:$line ${match.group(1)}');
        }
      }
    }

    expect(
      missing,
      isEmpty,
      reason:
          'Material\'s long-press menu paints itself with the theme\'s '
          '`surface` (brand yellow) and `onSurface` (grey). Pass '
          '`contextMenuBuilder: appContextMenuBuilder` from '
          'core/presentation/widgets/text_fields/app_context_menu.dart so the '
          'menu is white with black labels.',
    );
  });
}
