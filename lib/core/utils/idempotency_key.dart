import 'package:nowdelivery_user_app/core/utils/uuid.dart';













class IdempotencyKey {
  String? _key;
  String? _fingerprint;
  bool _consumed = false;





  String forRequest(String fingerprint, {String Function()? generate}) {
    if (_key == null || _consumed || fingerprint != _fingerprint) {
      _key = (generate ?? generateUuidV4)();
      _fingerprint = fingerprint;
      _consumed = false;
    }
    return _key!;
  }



  void markConsumed() => _consumed = true;
}
