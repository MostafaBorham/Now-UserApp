import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A `Failure(exception.toString())` puts a Dart error ("type 'Null' is not a
/// subtype of…") in front of the customer, because every failure message is
/// shown. It was removed repo by repo over four review phases; this keeps it
/// from coming back.
void main() {
  test('no Failure is built from an exception\'s text', () {
    final RegExp raw = RegExp(r'Failure\(\s*\w+\.toString\(\)\s*\)');
    final List<String> offenders = <String>[
      for (final FileSystemEntity entity
          in Directory('lib').listSync(recursive: true))
        if (entity is File &&
            entity.path.endsWith('.dart') &&
            raw.hasMatch(entity.readAsStringSync()))
          entity.path,
    ];

    expect(
      offenders,
      isEmpty,
      reason: 'Return a LangKeys key (e.g. serverConnectionFailedKey) instead.',
    );
  });
}
