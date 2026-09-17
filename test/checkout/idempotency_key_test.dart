import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/utils/idempotency_key.dart';
import 'package:nowdelivery_user_app/core/utils/uuid.dart';




void main() {
  test('reuses the key for the same fingerprint', () {
    final key = IdempotencyKey();
    int n = 0;
    String gen() => 'k${n++}';

    final first = key.forRequest('addr1|tip0|coupons', generate: gen);
    final retry = key.forRequest('addr1|tip0|coupons', generate: gen);

    expect(first, 'k0');
    expect(retry, 'k0');
  });

  test('rotates the key when the fingerprint changes', () {
    final key = IdempotencyKey();
    int n = 0;
    String gen() => 'k${n++}';

    final before = key.forRequest('addr1|tip0', generate: gen);
    final afterEdit = key.forRequest('addr2|tip0', generate: gen);

    expect(before, 'k0');
    expect(afterEdit, 'k1');
  });

  test('rotates after a placement even if the fingerprint matches', () {
    final key = IdempotencyKey();
    int n = 0;
    String gen() => 'k${n++}';

    final placed = key.forRequest('same', generate: gen);
    key.markConsumed();
    final reorder = key.forRequest('same', generate: gen);

    expect(placed, 'k0');
    expect(reorder, 'k1');
  });

  test('generateUuidV4 is a well-formed v4 uuid', () {
    final id = generateUuidV4();
    expect(
      RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ).hasMatch(id),
      isTrue,
    );
    expect(generateUuidV4(), isNot(id));
  });
}
