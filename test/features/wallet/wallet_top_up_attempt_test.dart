import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_top_up_attempt.dart';

void main() {
  const WalletTopUpAttempt attempt = WalletTopUpAttempt(
    amountHalalas: 30000,
    paymentMethodId: 12,
    idempotencyKey: '9e377bf3-9487-4321-8901-c3cd85df3a72',
  );

  group('matches', () {
    test('a retry of the same submit reuses the attempt', () {
      // If this goes false, the retry mints a new key and the server records a
      // second top-up instead of replaying the first.
      expect(
        attempt.matches(amountHalalas: 30000, paymentMethodId: 12),
        isTrue,
      );
    });

    test('a different amount or card is a new top-up, not a retry', () {
      // If either of these goes true, a genuine second top-up replays the first
      // one's result and the customer's money never moves.
      expect(
        attempt.matches(amountHalalas: 30001, paymentMethodId: 12),
        isFalse,
      );
      expect(
        attempt.matches(amountHalalas: 30000, paymentMethodId: 13),
        isFalse,
      );
    });
  });

  group('fromJson', () {
    test('round-trips through the stored payload', () {
      final WalletTopUpAttempt? restored = WalletTopUpAttempt.fromJson(
        jsonDecode(jsonEncode(attempt.toJson())) as Map<String, dynamic>,
      );

      expect(restored, attempt);
    });

    test('treats an incomplete record as no attempt', () {
      // A malformed payload must not block every future top-up.
      for (final Map<String, dynamic> json in <Map<String, dynamic>>[
        <String, dynamic>{},
        <String, dynamic>{'amount_halalas': 30000, 'payment_method_id': 12},
        <String, dynamic>{
          'amount_halalas': 30000,
          'payment_method_id': 12,
          'idempotency_key': '',
        },
        <String, dynamic>{
          'payment_method_id': 12,
          'idempotency_key': 'abcdefgh',
        },
      ]) {
        expect(WalletTopUpAttempt.fromJson(json), isNull, reason: '$json');
      }
    });
  });
}
