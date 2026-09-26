import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/auth/data/repo/auth_repo.dart';

void main() {
  group('AuthRepo.recentlySentRetryAfter', () {
    test('the resend cooldown means a code is already on its way', () {
      // OtpRecentlyIssuedException::render
      expect(
        AuthRepo.recentlySentRetryAfter(
          statusCode: 429,
          body: <String, dynamic>{
            'success': false,
            'message': 'A code was sent recently.',
            'code': 429,
            'retry_after': 42,
          },
        ),
        42,
      );
    });

    test("the limiter's 429 is an error: nothing was sent", () {
      // RateLimiter::for('auth.otp') — note `retry_after_seconds`, not
      // `retry_after`. Treating this as sent put a locked-out user on the code
      // screen, where verify fails on the same budget.
      expect(
        AuthRepo.recentlySentRetryAfter(
          statusCode: 429,
          body: <String, dynamic>{
            'success': false,
            'message': 'Too many attempts.',
            'code': 429,
            'retry_after_ms': 180000,
            'retry_after_seconds': 180,
            'attempts_remaining': 0,
          },
        ),
        isNull,
      );
    });

    test('only a 429 counts', () {
      expect(
        AuthRepo.recentlySentRetryAfter(
          statusCode: 422,
          body: <String, dynamic>{'retry_after': 42},
        ),
        isNull,
      );
      expect(
        AuthRepo.recentlySentRetryAfter(statusCode: 429, body: null),
        isNull,
      );
    });

    test('a negative wait is clamped to zero', () {
      expect(
        AuthRepo.recentlySentRetryAfter(
          statusCode: 429,
          body: <String, dynamic>{'retry_after': -3},
        ),
        0,
      );
    });
  });
}
