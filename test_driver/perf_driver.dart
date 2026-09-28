import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

/// Host side of `integration_test/home_perf_test.dart`: writes each scenario's
/// frame-timing summary to `build/perf/<PERF_LABEL>/<scenario>.json`.
Future<void> main() => integrationDriver(
  responseDataCallback: (Map<String, dynamic>? data) async {
    final String label = Platform.environment['PERF_LABEL'] ?? 'run';
    for (final MapEntry<String, dynamic> scenario
        in (data ?? const <String, dynamic>{}).entries) {
      await writeResponseData(
        scenario.value as Map<String, dynamic>,
        testOutputFilename: scenario.key,
        destinationDirectory: 'build/perf/$label',
      );
    }
  },
);
