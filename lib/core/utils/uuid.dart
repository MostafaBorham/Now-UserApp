import 'dart:math';

/// Generates a random RFC-4122 version-4 UUID (36 chars) without a package
/// dependency. Used for idempotency keys on the place/confirm request.
String generateUuidV4() {
  final Random rng = Random.secure();
  final List<int> bytes = List<int>.generate(16, (_) => rng.nextInt(256));

  // Set the version (4) and variant (RFC 4122) bits.
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  final String hex = bytes
      .map((int b) => b.toRadixString(16).padLeft(2, '0'))
      .join();

  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
