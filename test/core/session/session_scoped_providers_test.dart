import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Non-`autoDispose` providers that deliberately outlive the session: app-wide
/// content, device state, or the orchestrator itself.
///
/// Anything holding data that belongs to *one user* does not go here — it goes
/// in `sessionScopedProviders` in `auth_session_vm.dart`, which is what actually
/// invalidates it when the session changes. Adding a name here only excuses it
/// from this check; it drops nothing at runtime.
const Set<String> _appScoped = <String>{
  'authSessionProvider', // the orchestrator itself
  'currentLocationProvider', // where the device is, not who is signed in
  'getAppInfoProvider', // the app's own text blocks and FAQs
  'getAppCategoriesProvider', // CategoryModel carries no per-user field
  'getHeaderBannersProvider', // banner images, identical for everyone
  'welcomeVoucherProvider', // one fixed public coupon, same for everyone
  'checkoutDiscountProvider', // stateless calculator, holds no state at all
};

/// A top-level `final [Type] name = SomeProvider...` declaration.
///
/// `^final` (start of line, no indent) keeps locals and class fields out.
/// `[^=;]` is a negated class, so it spans newlines — which it must, because
/// `final getCartProvider =\n    StateNotifierProvider<...>` is the common
/// style here. The constructor group stops at the first `<` or `(`, so a match
/// can never run far enough to swallow the declaration after it; a greedy tail
/// would silently hide providers rather than fail.
final RegExp _declaration = RegExp(
  r'^final\s+([^=;]{0,200}?)=\s*([A-Za-z_][A-Za-z0-9_.]*)',
  multiLine: true,
);

final RegExp _identifier = RegExp(r'[A-Za-z_][A-Za-z0-9_]*');

void main() {
  test('every kept-alive provider is classified session- or app-scoped', () {
    const String vmPath = 'lib/features/auth/viewmodel/auth_session_vm.dart';
    final String sessionVm = File(vmPath).readAsStringSync();

    // ponytail: the list is matched as text, not imported. A provider object
    // carries no variable name at runtime and `dart:mirrors` is unavailable
    // under `flutter test`. Slicing out just the list — rather than searching
    // the whole file — is what stops a provider that is merely *fetched* by
    // `_loadUserDependencies` from passing as one that is purged.
    const String marker = 'sessionScopedProviders = <ProviderOrFamily>[';
    final int start = sessionVm.indexOf(marker);

    expect(
      start,
      isNot(-1),
      reason: 'Could not find `$marker` in $vmPath. If the list was renamed or '
          'reformatted, update the marker in this test.',
    );

    final String sessionList = sessionVm.substring(
      start,
      sessionVm.indexOf('];', start),
    );

    final Set<String> seen = <String>{};
    final List<String> unclassified = <String>[];

    for (final FileSystemEntity entity
        in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final String source = entity.readAsStringSync();

      for (final RegExpMatch match in _declaration.allMatches(source)) {
        final String declaration = match.group(1)!;
        final String constructor = match.group(2)!;

        if (!constructor.contains('Provider')) continue;

        // An autoDispose provider dies with its last listener, so by the time
        // the session changes there is nothing of the old user left to purge.
        // The second arm catches the one explicitly annotated declaration
        // (`final AutoDisposeStateProvider<int> x = StateProvider.autoDispose`).
        if (constructor.contains('autoDispose') ||
            declaration.contains('AutoDispose')) {
          continue;
        }

        final String name = _identifier.allMatches(declaration).last.group(0)!;

        seen.add(name);

        if (_appScoped.contains(name)) continue;
        if (RegExp('\\b$name\\b').hasMatch(sessionList)) continue;

        unclassified.add('  $name  (${entity.path})');
      }
    }

    expect(
      unclassified,
      isEmpty,
      reason:
          'These providers are kept alive for the whole app life cycle, and '
          'nothing drops them when the signed-in user changes:\n'
          '${unclassified.join('\n')}\n\n'
          'If it holds data belonging to the signed-in user, add it to '
          '`sessionScopedProviders` in $vmPath — that is what invalidates it '
          'on logout. If it is app-wide content or device state, add its name '
          'to `_appScoped` in this test with a one-line reason.',
    );

    // Exemptions rot too: a renamed or deleted provider would sit in the set
    // forever, quietly excusing nothing.
    expect(
      _appScoped.difference(seen),
      isEmpty,
      reason: 'Exempt in this test but no longer declared in lib/ — remove '
          'them from `_appScoped`.',
    );
  });
}
