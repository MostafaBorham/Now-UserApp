import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

// BUG-021: a URL that failed once was skipped for the rest of the session, so
// a store cover that failed (or wasn't uploaded yet) never showed.
void main() {
  test('a failed URL is skipped for a minute, then retried', () {
    const String url = 'https://x/cover.png';
    AppCachedNetworkImage.rememberFailedUrl(url);
    final DateTime now = DateTime.now();

    expect(AppCachedNetworkImage.recentlyFailed(url, now: now), isTrue);
    expect(
      AppCachedNetworkImage.recentlyFailed(
        url,
        now: now.add(const Duration(seconds: 61)),
      ),
      isFalse,
    );
    // Retried means forgotten: it isn't skipped again until it fails again.
    expect(AppCachedNetworkImage.recentlyFailed(url, now: now), isFalse);
  });
}
